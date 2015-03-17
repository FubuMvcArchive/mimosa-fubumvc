"use strict";
var log, logger, path, printObj, relativeToThisFile, _;

logger = require('logmimosa');

path = require('path');

_ = require('lodash');

log = function(level, statement) {
  return logger[level]("fubumvc: " + statement);
};

relativeToThisFile = function(filePath, dirname) {
  if (dirname == null) {
    dirname = __dirname;
  }
  return path.join(dirname, filePath);
};

printObj = function(obj, prefix) {
  var withPrefix;
  withPrefix = function(x) {
    if (prefix != null) {
      return prefix + "." + x;
    } else {
      return x;
    }
  };
  return _.each(obj, function(v, k) {
    if (_.isObject(v)) {
      return printObj(v, withPrefix(k));
    } else {
      return console.log((withPrefix(k)) + ": " + v);
    }
  });
};

module.exports = {
  log: log,
  relativeToThisFile: relativeToThisFile,
  printObj: printObj
};
