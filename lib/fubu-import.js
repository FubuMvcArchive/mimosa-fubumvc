"use strict";
var Rx, buildExtensions, clean, cleanAssets, color, copyFile, deleteDirectory, deleteFile, deleteFileSync, excludeStrategies, findBottles, findSourceFiles, fs, getTargets, importAssets, isExcludedByConfig, log, matchesWithoutBaseDir, parseString, parseXml, path, prepareFileWatcher, printObj, setWorkingDir, shouldInclude, startWatching, trackCompletion, transformPath, watch, withoutBaseDir, withoutPath, workingDir, wrench, _, _ref;

_ref = require('./util'), log = _ref.log, printObj = _ref.printObj;

color = require('ansi-color').set;

fs = require('fs');

path = require('path');

watch = require('chokidar');

wrench = require('wrench');

_ = require('lodash');

parseString = require('xml2js').parseString;

workingDir = process.cwd();

Rx = require("rx");

findSourceFiles = function(from, extensions, excludes, baseDir) {
  return wrench.readdirSyncRecursive(from).filter(function(f) {
    var isFile, isIncluded, originalFile;
    originalFile = path.join(from, f);
    isFile = fs.statSync(originalFile).isFile();
    isIncluded = shouldInclude(f, isFile, extensions, excludes, baseDir);
    return isIncluded && isFile;
  }).map(function(f) {
    return path.join(from, f);
  });
};

shouldInclude = function(f, isFile, extensions, excludes, baseDir) {
  var atRoot, excluded, ext, matchesExtension;
  extensions = extensions.map(function(ext) {
    return "." + ext;
  });
  ext = path.extname(f);
  matchesExtension = !isFile || _.contains(extensions, ext);
  atRoot = isFile && f.indexOf(path.sep) === -1;
  excluded = isExcludedByConfig(f, excludes, baseDir);
  return matchesExtension && !excluded && !atRoot;
};

withoutPath = function(fromPath) {
  return function(input) {
    return input.replace("" + fromPath + path.sep, '');
  };
};

prepareFileWatcher = function(from, extensions, excludes, isBuild, fileWatcherSettings, baseDir) {
  var adds, changes, errors, files, fixPath, numberOfFiles, observableFor, settings, unlinks, watchSettings, watcher;
  files = findSourceFiles(from, extensions, excludes, baseDir);
  numberOfFiles = files.length;
  fixPath = withoutPath(from);
  settings = {
    ignored: function(file) {
      var f, isFile;
      isFile = fs.statSync(file).isFile();
      f = fixPath(file);
      return !(shouldInclude(f, isFile, extensions, excludes, baseDir));
    },
    persistent: !isBuild
  };
  watchSettings = _.extend(settings, fileWatcherSettings);
  observableFor = function(event) {
    return Rx.Observable.fromEvent(watcher, event);
  };
  log("debug", "starting file watcher on [[ " + from + " ]] usePolling: " + watchSettings.usePolling);
  watcher = watch.watch(from, watchSettings);
  adds = observableFor("add");
  changes = observableFor("change");
  unlinks = observableFor("unlink");
  errors = (observableFor("error")).selectMany(function(e) {
    return Rx.Observable["throw"](e);
  });
  return {
    numberOfFiles: numberOfFiles,
    adds: adds,
    changes: changes,
    unlinks: unlinks,
    errors: errors
  };
};

startWatching = function(from, _arg, options, cb) {
  var adds, changes, deletes, errors, fromSource, initialCopy, numberOfFiles, unlinks;
  numberOfFiles = _arg.numberOfFiles, adds = _arg.adds, changes = _arg.changes, unlinks = _arg.unlinks, errors = _arg.errors;
  fromSource = function(obs) {
    return obs.merge(errors);
  };
  initialCopy = fromSource(adds).take(numberOfFiles);
  initialCopy.subscribe(function(f) {
    return copyFile(f, from, options);
  }, function(e) {
    log("warn", "File watching error: " + e);
    if (cb) {
      return cb();
    }
  }, function() {
    var ongoingCopy;
    ongoingCopy = fromSource(adds.merge(changes));
    ongoingCopy.subscribe(function(f) {
      return copyFile(f, from, options);
    }, function(e) {
      return log("warn", "File watching error: " + e);
    });
    log("info", "finished initial copy for: " + from);
    if (cb) {
      return cb();
    }
  });
  deletes = fromSource(unlinks);
  return deletes.subscribe(function(f) {
    var outFile;
    outFile = transformPath(f, from, options);
    return deleteFile(outFile);
  }, function(e) {
    return log("warn", "File watching errors: " + e);
  });
};

copyFile = function(file, from, options) {
  return fs.readFile(file, function(err, data) {
    var dirname, outFile;
    if (err) {
      log("error", "Error reading file [[ " + file + " ]], " + err);
      return;
    }
    outFile = transformPath(file, from, options);
    dirname = path.dirname(outFile);
    if (!fs.existsSync(dirname)) {
      wrench.mkdirSyncRecursive(dirname, 0x1ff);
    }
    return fs.writeFile(outFile, data, function(err) {
      if (err) {
        return log("error", "Error reading file [[ " + file + " ]], " + err);
      } else {
        return log("success", "File copied to destination [[ " + outFile + " ]] from [[ " + file + " ]]");
      }
    });
  });
};

deleteFileSync = function(file) {
  if (fs.existsSync(file)) {
    fs.unlinkSync(file);
    return log("success", "File [[ " + file + " ]] deleted.");
  }
};

deleteFile = function(file) {
  return fs.exists(file, function(exists) {
    if (exists) {
      return fs.unlink(file, function(err) {
        if (err) {
          return log("error", "Error deleting file [[ " + file + " ]], " + err);
        } else {
          return log("success", "File [[ " + file + " ]] deleted.");
        }
      });
    }
  });
};

deleteDirectory = function(dir, cb) {
  if (fs.existsSync(dir)) {
    return fs.rmdir(dir, function(err) {
      if ((err != null ? err.code : void 0) === !"ENOTEMPTY") {
        log("error", "Unable to delete directory [[ " + dir + " ]]");
        log("error", err);
      } else {
        log("info", "Deleted empty directory [[ " + dir + " ]]");
      }
      if (cb) {
        return cb();
      }
    });
  } else {
    if (cb) {
      return cb();
    }
  }
};

withoutBaseDir = function(testPath, baseDir) {
  var cwd, newPath, returnVal, start;
  baseDir = baseDir && baseDir.length ? path.join(baseDir, "/") : baseDir;
  cwd = process.cwd();
  newPath = testPath.replace(cwd, "");
  start = Math.max(newPath.indexOf(baseDir), 0);
  newPath = newPath.substring(start);
  returnVal = newPath.replace(baseDir || "", "").replace(/^\/|^\\/, "");
  return returnVal;
};

transformPath = function(file, from, _arg) {
  var baseDir, conventions, finalPath, fixPath, newFile, newFilePath, newSourceDir, result, sourceDir;
  sourceDir = _arg.sourceDir, conventions = _arg.conventions, baseDir = _arg.baseDir;
  newFilePath = withoutBaseDir(file, baseDir);
  newSourceDir = withoutBaseDir(sourceDir, baseDir);
  fixPath = withoutPath(from);
  newFile = fixPath(newFilePath);
  result = _.reduce(conventions, function(acc, _arg1) {
    var ext, match, transform;
    match = _arg1.match, transform = _arg1.transform;
    ext = path.extname(acc);
    if (match(acc, ext, log)) {
      return transform(acc, path, log);
    } else {
      return acc;
    }
  }, newFile);
  result = result.replace(newSourceDir, "");
  finalPath = path.join(baseDir || "", newSourceDir, result);
  return finalPath;
};

matchesWithoutBaseDir = function(testPath, baseDir, predicate) {
  var newTest, shouldExclude;
  newTest = withoutBaseDir(testPath, baseDir);
  shouldExclude = predicate(newTest);
  return shouldExclude;
};

excludeStrategies = {
  string: {
    identity: _.isString,
    predicate: function(ex, testPath, baseDir) {
      return matchesWithoutBaseDir(testPath, baseDir, function(newPath) {
        return newPath.indexOf(ex) === 0;
      });
    }
  },
  regex: {
    identity: _.isRegExp,
    predicate: function(ex, testPath, baseDir) {
      return matchesWithoutBaseDir(testPath, baseDir, function(newPath) {
        return ex.test(newPath);
      });
    }
  }
};

isExcludedByConfig = function(testPath, excludes, baseDir) {
  var ofType;
  ofType = function(method) {
    return excludes.filter(function(f) {
      return method(f);
    });
  };
  return _.any(excludeStrategies, function(_arg) {
    var identity, predicate;
    identity = _arg.identity, predicate = _arg.predicate;
    return _.any(ofType(identity), function(ex) {
      return predicate(ex, testPath, baseDir);
    });
  });
};

parseXml = function(content) {
  var result;
  result = {};
  parseString(content, function(err, output) {
    return result = output;
  });
  return result;
};

findBottles = function(sourceDir) {
  var bottles, data, encoding, linksFile, linksXml, _ref1;
  linksFile = path.join(sourceDir, ".links");
  if (fs.existsSync(linksFile)) {
    encoding = "utf8";
    data = fs.readFileSync(linksFile, {
      encoding: encoding
    });
    linksXml = parseXml(data);
    bottles = (linksXml != null ? (_ref1 = linksXml.links) != null ? _ref1.include : void 0 : void 0) || [];
    if (!(bottles && _.isArray(bottles))) {
      log("error", ".links file not valid");
      return;
    }
    bottles = _.map(bottles, function(bottle) {
      return bottle.replace(/\\|\//, path.sep);
    });
    return bottles;
  } else {
    return [];
  }
};

buildExtensions = function(config) {
  var copy, css, extensions, javascript, _ref1;
  _ref1 = config.extensions, copy = _ref1.copy, javascript = _ref1.javascript, css = _ref1.css;
  return extensions = _.union(copy, javascript, css);
};

setWorkingDir = function(val) {
  return workingDir = val || process.cwd();
};

importAssets = function(mimosaConfig, options, next) {
  var baseDir, binaryInterval, compiledDir, conventions, excludePaths, extensions, fileWatcherSettings, finish, importFrom, interval, isBuild, sourceDir, targets, usePolling, _ref1;
  log("info", "importing assets");
  _ref1 = mimosaConfig.fubumvc, excludePaths = _ref1.excludePaths, sourceDir = _ref1.sourceDir, compiledDir = _ref1.compiledDir, isBuild = _ref1.isBuild, conventions = _ref1.conventions, usePolling = _ref1.usePolling, interval = _ref1.interval, binaryInterval = _ref1.binaryInterval, baseDir = _ref1.baseDir;
  extensions = buildExtensions(mimosaConfig);
  setWorkingDir(baseDir);
  log("debug", "allowed extensions [[ " + extensions + " ]]");
  log("debug", "excludePaths [[ " + excludePaths + " ]]");
  fileWatcherSettings = {
    usePolling: usePolling,
    interval: interval,
    binaryInterval: binaryInterval
  };
  importFrom = function(target, callback) {
    var fileWatcher;
    log("info", "watching " + target);
    fileWatcher = prepareFileWatcher(target, extensions, excludePaths, isBuild, fileWatcherSettings, mimosaConfig.fubumvc.baseDir);
    return startWatching(target, fileWatcher, {
      sourceDir: sourceDir,
      conventions: conventions,
      baseDir: baseDir
    }, callback);
  };
  targets = getTargets(workingDir);
  finish = trackCompletion("importAssets", targets, next);
  _.each(targets, function(target) {
    return importFrom(target, function() {
      return finish(target);
    });
  });
};

getTargets = function(dir) {
  var bottles, targets;
  bottles = _.map(findBottles(dir), function(bottle) {
    return path.resolve(dir, bottle);
  });
  return targets = [].concat(bottles, [dir]);
};

cleanAssets = function(mimosaConfig, options, next) {
  var allTargetFiles, baseDir, compiledDir, conventions, excludePaths, extensions, filesFor, finish, isBuild, sourceDir, targets, _ref1;
  log("info", "cleaning assets");
  _ref1 = mimosaConfig.fubumvc, extensions = _ref1.extensions, excludePaths = _ref1.excludePaths, sourceDir = _ref1.sourceDir, compiledDir = _ref1.compiledDir, isBuild = _ref1.isBuild, conventions = _ref1.conventions, baseDir = _ref1.baseDir;
  extensions = buildExtensions(mimosaConfig);
  options = {
    sourceDir: sourceDir,
    conventions: conventions,
    baseDir: baseDir
  };
  setWorkingDir(baseDir);
  filesFor = function(target) {
    var files, outputFiles;
    log("debug", "finding files for: " + target + " with extensions: " + extensions + " and excludePaths: " + excludePaths);
    files = findSourceFiles(target, extensions, excludePaths, baseDir);
    outputFiles = _.map(files, function(f) {
      return transformPath(f, target, options);
    });
    return [target, files, outputFiles];
  };
  targets = getTargets(workingDir);
  allTargetFiles = _.map(targets, filesFor);
  finish = trackCompletion("cleanAssets", targets, next);
  _.each(allTargetFiles, function(_arg) {
    var files, outputFiles, target;
    target = _arg[0], files = _arg[1], outputFiles = _arg[2];
    return clean([target, files, outputFiles], function() {
      return finish(target);
    });
  });
};

trackCompletion = function(title, initial, cb) {
  var done, remaining;
  remaining = [].concat(initial);
  done = function(dir) {
    remaining = _.without(remaining, dir);
    if (remaining.length === 0) {
      log("info", "finished " + title);
      return cb();
    }
  };
  return done;
};

clean = function(_arg, cb) {
  var dirs, files, finish, outputFiles, target;
  target = _arg[0], files = _arg[1], outputFiles = _arg[2];
  _.each(outputFiles, function(f) {
    return deleteFileSync(f);
  });
  dirs = _(outputFiles).map(function(f) {
    return path.dirname(f);
  }).unique().sortBy("length").reverse().value();
  if (dirs.length > 0) {
    finish = trackCompletion("clean", dirs, cb);
    return _(dirs).map(function(dir) {
      return [
        dir, function() {
          return finish(dir);
        }
      ];
    }).each(function(_arg1) {
      var cb, dir;
      dir = _arg1[0], cb = _arg1[1];
      return deleteDirectory(dir, cb);
    });
  } else {
    return cb();
  }
};

module.exports = {
  importAssets: importAssets,
  cleanAssets: cleanAssets
};
