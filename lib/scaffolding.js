"use strict";
var Bliss, bliss, copyContents, cwd, deleteFolders, filesAtBase, fs, initFiles, log, makeFolders, path, relativeToThisFile, removeAllFilesFromDirectory, resetFileSystem, setupFileSystem, setupFileSystemWithConfig, wrench, _, _ref;

fs = require('fs');

path = require('path');

wrench = require('wrench');

_ = require('lodash');

_ref = require('./util'), log = _ref.log, relativeToThisFile = _ref.relativeToThisFile;

Bliss = require('bliss');

bliss = new Bliss({
  ext: ".bliss",
  cacheEnabled: false,
  context: {}
});

cwd = process.cwd();

setupFileSystem = function(args, retrieveConfig) {
  return retrieveConfig({
    buildFirst: false
  }, function(config) {
    return setupFileSystemWithConfig(config, args);
  });
};

setupFileSystemWithConfig = function(config, args) {
  var baseDir;
  baseDir = config.fubumvc ? config.fubumvc.baseDir : cwd;
  makeFolders(baseDir);
  return initFiles(args, baseDir);
};

resetFileSystem = function(args, retrieveConfig) {
  return retrieveConfig({
    buildFirst: false
  }, function(config) {
    var baseDir;
    baseDir = config.fubumvc ? config.fubumvc.baseDir : cwd;
    deleteFolders(baseDir);
    return setupFileSystem(args, retrieveConfig);
  });
};

makeFolders = function(baseDir) {
  var folders;
  if (baseDir == null) {
    baseDir = "";
  }
  folders = ['assets/scripts', 'assets/styles', 'public'];
  return _.each(folders, function(dir) {
    var target;
    if (!fs.existsSync(dir)) {
      target = path.join(baseDir, dir);
      log("info", "creating " + target);
      return wrench.mkdirSyncRecursive(target, 0x1ff);
    }
  });
};

removeAllFilesFromDirectory = function(folder, keep) {
  return fs.readdirSync(folder).forEach(function(file) {
    var err, isDir, targetFile;
    targetFile = path.join(folder, file);
    isDir = fs.lstatSync(targetFile).isDirectory();
    if (file === keep) {
      if (isDir) {
        removeAllFilesFromDirectory(targetFile);
      }
      return;
    }
    try {
      if (isDir) {
        return wrench.rmdirSyncRecursive(targetFile);
      } else {
        if (/\.gitignore/.test(targetFile)) {
          return;
        }
        fs.unlinkSync(targetFile);
        return log("success", "deleted " + targetFile);
      }
    } catch (_error) {
      err = _error;
      return log("error", err);
    }
  });
};

deleteFolders = function(baseDir) {
  var folders;
  if (baseDir == null) {
    baseDir = "";
  }
  folders = ['assets', 'public'];
  return _.each(folders, function(dir) {
    var target;
    target = path.join(baseDir, dir);
    return removeAllFilesFromDirectory(target, "scripts");
  });
};

filesAtBase = function(baseDir, files) {
  return _.map(files, function(f) {
    return path.join(baseDir, f);
  });
};

initFiles = function(flags, baseDir) {
  var contents, ext, fileWithContents, files, useCoffee, viewModel;
  if (flags == null) {
    flags = false;
  }
  if (baseDir == null) {
    baseDir = "";
  }
  useCoffee = flags === "coffee";
  ext = useCoffee ? "coffee" : "js";
  files = ["bower.json", "mimosa-config." + ext, "assets/dont-delete-me.js"];
  viewModel = {
    name: path.basename(cwd)
  };
  contents = _(files).map(function(f) {
    return relativeToThisFile(path.join("../fubu-import-templates/", f));
  }).map(function(f) {
    return bliss.render(f, viewModel);
  }).map(function(f) {
    return f.trim();
  }).value();
  fileWithContents = _.zip(filesAtBase(baseDir, files), contents);
  _.each(fileWithContents, function(pair) {
    return copyContents(pair);
  });
};

copyContents = function(_arg) {
  var contents, fileName;
  fileName = _arg[0], contents = _arg[1];
  if (!fs.existsSync(fileName)) {
    log("info", "creating " + fileName);
    return fs.writeFileSync(fileName, contents);
  }
};

module.exports = {
  setupFileSystem: setupFileSystem,
  resetFileSystem: resetFileSystem,
  setupFileSystemWithConfig: setupFileSystemWithConfig
};
