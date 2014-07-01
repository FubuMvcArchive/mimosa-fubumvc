"use strict";
var path, _;

_ = require("lodash");

path = require('path');

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

exports.placeholder = function() {
  return "\t\n\n# fubumvc:\n  # usePolling: true\n  # interval: 500\n  # binaryInterval: 1000\n  # excludePaths: [\"bin\", \"obj\", /^\./]\n  # conventions: [\n    # provide 0 or more conventions\n    # { \n      # match: (file, ext, log) ->\n        # true #filename and extension, return true/false,\n      # transform: (file, path, log) ->\n        # file #filename and path module to do path.join, etc\n    # }\n  # ]";
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
  if (!((baseDir == null) || ((baseDir != null) && path.existsSync(baseDir)))) {
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

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiYzpcXHByb2plY3RzXFxtaW1vc2EtZnVidW12Y1xcbGliXFxjb25maWcuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJjOlxccHJvamVjdHNcXG1pbW9zYS1mdWJ1bXZjXFxzcmNcXGNvbmZpZy5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUEsWUFBQSxDQUFBO0FBQUEsSUFBQSxPQUFBOztBQUFBLENBRUEsR0FBSSxPQUFBLENBQVEsUUFBUixDQUZKLENBQUE7O0FBQUEsSUFHQSxHQUFPLE9BQUEsQ0FBUSxNQUFSLENBSFAsQ0FBQTs7QUFBQSxPQUtPLENBQUMsUUFBUixHQUFtQixTQUFBLEdBQUE7U0FDakI7QUFBQSxJQUFBLE9BQUEsRUFDRTtBQUFBLE1BQUEsVUFBQSxFQUFZLElBQVo7QUFBQSxNQUNBLFFBQUEsRUFBVSxHQURWO0FBQUEsTUFFQSxjQUFBLEVBQWdCLElBRmhCO0FBQUEsTUFHQSxZQUFBLEVBQWMsQ0FBQyxLQUFELEVBQVEsS0FBUixFQUFlLEtBQWYsQ0FIZDtBQUFBLE1BSUEsV0FBQSxFQUFhLEVBSmI7S0FERjtJQURpQjtBQUFBLENBTG5CLENBQUE7O0FBQUEsT0FhTyxDQUFDLFdBQVIsR0FBc0IsU0FBQSxHQUFBO1NBQ3BCLDhaQURvQjtBQUFBLENBYnRCLENBQUE7O0FBQUEsT0FpQ08sQ0FBQyxRQUFSLEdBQW1CLFNBQUMsTUFBRCxFQUFTLFVBQVQsR0FBQTtBQUNqQixNQUFBLG1LQUFBO0FBQUEsRUFBQSxNQUFBLEdBQVMsRUFBVCxDQUFBO0FBQUEsRUFDQyxVQUFXLE9BQVgsT0FERCxDQUFBO0FBRUEsRUFBQSxJQUFBLENBQUEsQ0FBTyxpQkFBQSxJQUFhLENBQUMsQ0FBQyxRQUFGLENBQVcsT0FBWCxDQUFwQixDQUFBO0FBQ0UsSUFBQSxNQUFNLENBQUMsSUFBUCxDQUFZLGdCQUFaLENBQUEsQ0FBQTtBQUNBLFdBQU8sTUFBUCxDQUZGO0dBRkE7QUFBQSxFQU1DLHVCQUFBLFlBQUQsRUFBZSxzQkFBQSxX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ZCxDQUFBO0FBQUEsRUFrREEsTUFBTSxDQUFDLE9BQU8sQ0FBQyxZQUFmLEdBQThCLFlBQVksQ0FBQyxNQUFiLENBQW9CLFdBQXBCLENBbEQ5QixDQUFBO0FBQUEsRUFtREEsTUFBTSxDQUFDLE9BQU8sQ0FBQyxTQUFmLEdBQTJCLFNBbkQzQixDQUFBO0FBQUEsRUFvREEsTUFBTSxDQUFDLE9BQU8sQ0FBQyxXQUFmLEdBQTZCLFdBcEQ3QixDQUFBO0FBQUEsRUFxREEsTUFBTSxDQUFDLE9BQU8sQ0FBQyxPQUFmLEdBQXlCLE1BQU0sQ0FBQyxPQXJEaEMsQ0FBQTtTQXVEQSxPQXhEaUI7QUFBQSxDQWpDbkIsQ0FBQSIsInNvdXJjZXNDb250ZW50IjpbIlwidXNlIHN0cmljdFwiXG5cbl8gPSByZXF1aXJlIFwibG9kYXNoXCJcbnBhdGggPSByZXF1aXJlICdwYXRoJ1xuXG5leHBvcnRzLmRlZmF1bHRzID0gLT5cbiAgZnVidW12YzpcbiAgICB1c2VQb2xsaW5nOiB0cnVlXG4gICAgaW50ZXJ2YWw6IDUwMFxuICAgIGJpbmFyeUludGVydmFsOiAxMDAwXG4gICAgZXhjbHVkZVBhdGhzOiBbXCJiaW5cIiwgXCJvYmpcIiwgL15cXC4vXVxuICAgIGNvbnZlbnRpb25zOiBbXVxuXG5leHBvcnRzLnBsYWNlaG9sZGVyID0gLT5cbiAgXCJcIlwiXG4gIFxcdFxuXG4gICMgZnVidW12YzpcbiAgICAjIHVzZVBvbGxpbmc6IHRydWVcbiAgICAjIGludGVydmFsOiA1MDBcbiAgICAjIGJpbmFyeUludGVydmFsOiAxMDAwXG4gICAgIyBleGNsdWRlUGF0aHM6IFtcImJpblwiLCBcIm9ialwiLCAvXlxcLi9dXG4gICAgIyBjb252ZW50aW9uczogW1xuICAgICAgIyBwcm92aWRlIDAgb3IgbW9yZSBjb252ZW50aW9uc1xuICAgICAgIyB7IFxuICAgICAgICAjIG1hdGNoOiAoZmlsZSwgZXh0LCBsb2cpIC0+XG4gICAgICAgICAgIyB0cnVlICNmaWxlbmFtZSBhbmQgZXh0ZW5zaW9uLCByZXR1cm4gdHJ1ZS9mYWxzZSxcbiAgICAgICAgIyB0cmFuc2Zvcm06IChmaWxlLCBwYXRoLCBsb2cpIC0+XG4gICAgICAgICAgIyBmaWxlICNmaWxlbmFtZSBhbmQgcGF0aCBtb2R1bGUgdG8gZG8gcGF0aC5qb2luLCBldGNcbiAgICAgICMgfVxuICAgICMgXVxuICBcIlwiXCJcblxuZXhwb3J0cy52YWxpZGF0ZSA9IChjb25maWcsIHZhbGlkYXRvcnMpIC0+XG4gIGVycm9ycyA9IFtdXG4gIHtmdWJ1bXZjfSA9IGNvbmZpZ1xuICB1bmxlc3MgZnVidW12Yz8gYW5kIF8uaXNPYmplY3QgZnVidW12Y1xuICAgIGVycm9ycy5wdXNoIFwiZnVidW12YyBjb25maWdcIlxuICAgIHJldHVybiBlcnJvcnNcblxuICB7ZXhjbHVkZVBhdGhzLCBjb252ZW50aW9ucywgdXNlUG9sbGluZywgaW50ZXJ2YWwsIGJpbmFyeUludGVydmFsLCBiYXNlRGlyfSA9IGZ1YnVtdmNcblxuICB1bmxlc3MgIWJhc2VEaXI/IG9yIChiYXNlRGlyPyBhbmQgcGF0aC5leGlzdHNTeW5jIGJhc2VEaXIpXG4gICAgZXJyb3JzLnB1c2ggXCJmdWJ1bXZjLmJhc2VEaXJcIlxuICAgIHJldHVybiBlcnJvcnNcblxuICB1bmxlc3MgdXNlUG9sbGluZz8gYW5kIF8uaXNCb29sZWFuIHVzZVBvbGxpbmdcbiAgICBlcnJvcnMucHVzaCBcImZ1YnVtdmMudXNlUG9sbGluZ1wiXG4gICAgcmV0dXJuIGVycm9yc1xuXG4gIHVubGVzcyBpbnRlcnZhbD8gYW5kIF8uaXNOdW1iZXIgaW50ZXJ2YWxcbiAgICBlcnJvcnMucHVzaCBcImZ1YnVtdmMuaW50ZXJ2YWxcIlxuICAgIHJldHVybiBlcnJvcnNcblxuICB1bmxlc3MgYmluYXJ5SW50ZXJ2YWw/IGFuZCBfLmlzTnVtYmVyIGJpbmFyeUludGVydmFsXG4gICAgZXJyb3JzLnB1c2ggXCJmdWJ1bXZjLmJpbmFyeUludGVydmFsXCJcbiAgICByZXR1cm4gZXJyb3JzXG5cbiAgdW5sZXNzIGV4Y2x1ZGVQYXRocz8gYW5kIF8uaXNBcnJheSBleGNsdWRlUGF0aHNcbiAgICBlcnJvcnMucHVzaCBcImZ1YnVtdmMuZXhjbHVkZVBhdGhzXCJcbiAgICByZXR1cm4gZXJyb3JzXG5cbiAgZXhjbHVkZVBhdGhzT2sgPSBfLmFsbCBleGNsdWRlUGF0aHMsIChpdGVtKSAtPlxuICAgIF8uaXNTdHJpbmcoaXRlbSkgb3IgXy5pc1JlZ0V4cChpdGVtKVxuXG4gIHVubGVzcyBleGNsdWRlUGF0aHNPa1xuICAgIGVycm9ycy5wdXNoIFwiZnVidW12Yy5leGNsdWRlUGF0aHMgZW50cmllcyBtdXN0IGJlIGVpdGhlciBzdHJpbmdzIG9yIHJlZ2V4ZXNcIlxuICAgIHJldHVybiBlcnJvcnNcblxuICB1bmxlc3MgY29udmVudGlvbnM/IGFuZCBfLmlzQXJyYXkgY29udmVudGlvbnNcbiAgICBlcnJvcnMucHVzaCBcImZ1YnVtdmMuY29udmVudGlvbnNcIlxuICAgIHJldHVybiBlcnJvcnNcblxuICBjb252ZW50aW9uc09rID0gXy5hbGwgY29udmVudGlvbnMsIChpdGVtKSAtPlxuICAgIF8uaXNPYmplY3QoaXRlbSkgYW5kIF8uYWxsIFtcIm1hdGNoXCIsIFwidHJhbnNmb3JtXCJdLCAoZnVuYykgLT4gXy5pc0Z1bmN0aW9uIGl0ZW1bZnVuY11cblxuICB1bmxlc3MgY29udmVudGlvbnNPa1xuICAgIGVycm9ycy5wdXNoIFwiZnVidW12Yy5jb252ZW50aW9ucyBlbnRyaWVzIG11c3QgYmUgb2JqZWN0cyB3aXRoIG1hdGNoOiAoZmlsZSwgZXh0KSAtPiBhbmQgdHJhbnNmb3JtOiAoZmlsZSwgcGF0aCkgLT5cIlxuICAgIHJldHVybiBlcnJvcnNcblxuICAjYXV0by1pbmNsdWRlIHRoZSBzb3VyY2VEaXIgYW5kIGNvbXBpbGVkRGlyIGludG8gZXhjbHVkZVBhdGhzIGxpc3RcbiAge3dhdGNoOiB7c291cmNlRGlyLCBjb21waWxlZERpcn19ID0gY29uZmlnXG4gIGlnbm9yZVBhdGhzID0gXy5tYXAgW3NvdXJjZURpciwgY29tcGlsZWREaXIsICdub2RlX21vZHVsZXMnXSwgKHApIC0+IHBhdGguYmFzZW5hbWUgcFxuXG4gIGNvbmZpZy5mdWJ1bXZjLmV4Y2x1ZGVQYXRocyA9IGV4Y2x1ZGVQYXRocy5jb25jYXQgaWdub3JlUGF0aHNcbiAgY29uZmlnLmZ1YnVtdmMuc291cmNlRGlyID0gc291cmNlRGlyXG4gIGNvbmZpZy5mdWJ1bXZjLmNvbXBpbGVkRGlyID0gY29tcGlsZWREaXJcbiAgY29uZmlnLmZ1YnVtdmMuaXNCdWlsZCA9IGNvbmZpZy5pc0J1aWxkXG5cbiAgZXJyb3JzXG4iXX0=
