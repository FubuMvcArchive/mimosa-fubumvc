"use strict";
var fs, path, _;

_ = require("lodash");

path = require('path');

fs = require('fs');

exports.defaults = function() {
  return {
    fubumvc: {
      usePolling: true,
      interval: 500,
      binaryInterval: 1000,
      excludePaths: ["bin", "obj", /^\./],
      conventions: []
    }
  };
};

exports.validate = function(config, validators) {
  var baseDir, binaryInterval, compiledDir, conventions, conventionsOk, errors, excludePaths, excludePathsOk, fubumvc, ignorePaths, interval, sourceDir, usePolling, _ref;
  errors = [];
  fubumvc = config.fubumvc;
  if (!((fubumvc != null) && _.isObject(fubumvc))) {
    errors.push("fubumvc config");
    return errors;
  }
  excludePaths = fubumvc.excludePaths, conventions = fubumvc.conventions, usePolling = fubumvc.usePolling, interval = fubumvc.interval, binaryInterval = fubumvc.binaryInterval, baseDir = fubumvc.baseDir;
  if (!((baseDir == null) || ((baseDir != null) && fs.existsSync(baseDir)))) {
    errors.push("fubumvc.baseDir");
    return errors;
  }
  if (!((usePolling != null) && _.isBoolean(usePolling))) {
    errors.push("fubumvc.usePolling");
    return errors;
  }
  if (!((interval != null) && _.isNumber(interval))) {
    errors.push("fubumvc.interval");
    return errors;
  }
  if (!((binaryInterval != null) && _.isNumber(binaryInterval))) {
    errors.push("fubumvc.binaryInterval");
    return errors;
  }
  if (!((excludePaths != null) && _.isArray(excludePaths))) {
    errors.push("fubumvc.excludePaths");
    return errors;
  }
  excludePathsOk = _.all(excludePaths, function(item) {
    return _.isString(item) || _.isRegExp(item);
  });
  if (!excludePathsOk) {
    errors.push("fubumvc.excludePaths entries must be either strings or regexes");
    return errors;
  }
  if (!((conventions != null) && _.isArray(conventions))) {
    errors.push("fubumvc.conventions");
    return errors;
  }
  conventionsOk = _.all(conventions, function(item) {
    return _.isObject(item) && _.all(["match", "transform"], function(func) {
      return _.isFunction(item[func]);
    });
  });
  if (!conventionsOk) {
    errors.push("fubumvc.conventions entries must be objects with match: (file, ext) -> and transform: (file, path) ->");
    return errors;
  }
  _ref = config.watch, sourceDir = _ref.sourceDir, compiledDir = _ref.compiledDir;
  ignorePaths = _.map([sourceDir, compiledDir, 'node_modules'], function(p) {
    return path.basename(p);
  });
  config.fubumvc.excludePaths = excludePaths.concat(ignorePaths);
  config.fubumvc.sourceDir = sourceDir;
  config.fubumvc.compiledDir = compiledDir;
  config.fubumvc.isBuild = config.isBuild;
  return errors;
};
