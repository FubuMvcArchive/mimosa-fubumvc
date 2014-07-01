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

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiL1VzZXJzL3NtaXRobS9kZXYvbWltb3NhLWZ1YnVtdmMvbGliL2NvbmZpZy5qcyIsInNvdXJjZVJvb3QiOiIiLCJzb3VyY2VzIjpbIi9Vc2Vycy9zbWl0aG0vZGV2L21pbW9zYS1mdWJ1bXZjL3NyYy9jb25maWcuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBLFlBQUEsQ0FBQTtBQUFBLElBQUEsT0FBQTs7QUFBQSxDQUVBLEdBQUksT0FBQSxDQUFRLFFBQVIsQ0FGSixDQUFBOztBQUFBLElBR0EsR0FBTyxPQUFBLENBQVEsTUFBUixDQUhQLENBQUE7O0FBQUEsT0FLTyxDQUFDLFFBQVIsR0FBbUIsU0FBQSxHQUFBO1NBQ2pCO0FBQUEsSUFBQSxPQUFBLEVBQ0U7QUFBQSxNQUFBLFVBQUEsRUFBWSxJQUFaO0FBQUEsTUFDQSxRQUFBLEVBQVUsR0FEVjtBQUFBLE1BRUEsY0FBQSxFQUFnQixJQUZoQjtBQUFBLE1BR0EsWUFBQSxFQUFjLENBQUMsS0FBRCxFQUFRLEtBQVIsRUFBZSxLQUFmLENBSGQ7QUFBQSxNQUlBLFdBQUEsRUFBYSxFQUpiO0tBREY7SUFEaUI7QUFBQSxDQUxuQixDQUFBOztBQUFBLE9BYU8sQ0FBQyxXQUFSLEdBQXNCLFNBQUEsR0FBQTtTQUNwQiw4WkFEb0I7QUFBQSxDQWJ0QixDQUFBOztBQUFBLE9BaUNPLENBQUMsUUFBUixHQUFtQixTQUFDLE1BQUQsRUFBUyxVQUFULEdBQUE7QUFDakIsTUFBQSxtS0FBQTtBQUFBLEVBQUEsTUFBQSxHQUFTLEVBQVQsQ0FBQTtBQUFBLEVBQ0MsVUFBVyxPQUFYLE9BREQsQ0FBQTtBQUVBLEVBQUEsSUFBQSxDQUFBLENBQU8saUJBQUEsSUFBYSxDQUFDLENBQUMsUUFBRixDQUFXLE9BQVgsQ0FBcEIsQ0FBQTtBQUNFLElBQUEsTUFBTSxDQUFDLElBQVAsQ0FBWSxnQkFBWixDQUFBLENBQUE7QUFDQSxXQUFPLE1BQVAsQ0FGRjtHQUZBO0FBQUEsRUFNQyx1QkFBQSxZQUFELEVBQWUsc0JBQUEsV0FBZixFQUE0QixxQkFBQSxVQUE1QixFQUF3QyxtQkFBQSxRQUF4QyxFQUFrRCx5QkFBQSxjQUFsRCxFQUFrRSxrQkFBQSxPQU5sRSxDQUFBO0FBUUEsRUFBQSxJQUFBLENBQUEsQ0FBUSxpQkFBRCxJQUFhLENBQUMsaUJBQUEsSUFBYSxJQUFJLENBQUMsVUFBTCxDQUFnQixPQUFoQixDQUFkLENBQXBCLENBQUE7QUFDRSxJQUFBLE1BQU0sQ0FBQyxJQUFQLENBQVksaUJBQVosQ0FBQSxDQUFBO0FBQ0EsV0FBTyxNQUFQLENBRkY7R0FSQTtBQVlBLEVBQUEsSUFBQSxDQUFBLENBQU8sb0JBQUEsSUFBZ0IsQ0FBQyxDQUFDLFNBQUYsQ0FBWSxVQUFaLENBQXZCLENBQUE7QUFDRSxJQUFBLE1BQU0sQ0FBQyxJQUFQLENBQVksb0JBQVosQ0FBQSxDQUFBO0FBQ0EsV0FBTyxNQUFQLENBRkY7R0FaQTtBQWdCQSxFQUFBLElBQUEsQ0FBQSxDQUFPLGtCQUFBLElBQWMsQ0FBQyxDQUFDLFFBQUYsQ0FBVyxRQUFYLENBQXJCLENBQUE7QUFDRSxJQUFBLE1BQU0sQ0FBQyxJQUFQLENBQVksa0JBQVosQ0FBQSxDQUFBO0FBQ0EsV0FBTyxNQUFQLENBRkY7R0FoQkE7QUFvQkEsRUFBQSxJQUFBLENBQUEsQ0FBTyx3QkFBQSxJQUFvQixDQUFDLENBQUMsUUFBRixDQUFXLGNBQVgsQ0FBM0IsQ0FBQTtBQUNFLElBQUEsTUFBTSxDQUFDLElBQVAsQ0FBWSx3QkFBWixDQUFBLENBQUE7QUFDQSxXQUFPLE1BQVAsQ0FGRjtHQXBCQTtBQXdCQSxFQUFBLElBQUEsQ0FBQSxDQUFPLHNCQUFBLElBQWtCLENBQUMsQ0FBQyxPQUFGLENBQVUsWUFBVixDQUF6QixDQUFBO0FBQ0UsSUFBQSxNQUFNLENBQUMsSUFBUCxDQUFZLHNCQUFaLENBQUEsQ0FBQTtBQUNBLFdBQU8sTUFBUCxDQUZGO0dBeEJBO0FBQUEsRUE0QkEsY0FBQSxHQUFpQixDQUFDLENBQUMsR0FBRixDQUFNLFlBQU4sRUFBb0IsU0FBQyxJQUFELEdBQUE7V0FDbkMsQ0FBQyxDQUFDLFFBQUYsQ0FBVyxJQUFYLENBQUEsSUFBb0IsQ0FBQyxDQUFDLFFBQUYsQ0FBVyxJQUFYLEVBRGU7RUFBQSxDQUFwQixDQTVCakIsQ0FBQTtBQStCQSxFQUFBLElBQUEsQ0FBQSxjQUFBO0FBQ0UsSUFBQSxNQUFNLENBQUMsSUFBUCxDQUFZLGdFQUFaLENBQUEsQ0FBQTtBQUNBLFdBQU8sTUFBUCxDQUZGO0dBL0JBO0FBbUNBLEVBQUEsSUFBQSxDQUFBLENBQU8scUJBQUEsSUFBaUIsQ0FBQyxDQUFDLE9BQUYsQ0FBVSxXQUFWLENBQXhCLENBQUE7QUFDRSxJQUFBLE1BQU0sQ0FBQyxJQUFQLENBQVkscUJBQVosQ0FBQSxDQUFBO0FBQ0EsV0FBTyxNQUFQLENBRkY7R0FuQ0E7QUFBQSxFQXVDQSxhQUFBLEdBQWdCLENBQUMsQ0FBQyxHQUFGLENBQU0sV0FBTixFQUFtQixTQUFDLElBQUQsR0FBQTtXQUNqQyxDQUFDLENBQUMsUUFBRixDQUFXLElBQVgsQ0FBQSxJQUFxQixDQUFDLENBQUMsR0FBRixDQUFNLENBQUMsT0FBRCxFQUFVLFdBQVYsQ0FBTixFQUE4QixTQUFDLElBQUQsR0FBQTthQUFVLENBQUMsQ0FBQyxVQUFGLENBQWEsSUFBSyxDQUFBLElBQUEsQ0FBbEIsRUFBVjtJQUFBLENBQTlCLEVBRFk7RUFBQSxDQUFuQixDQXZDaEIsQ0FBQTtBQTBDQSxFQUFBLElBQUEsQ0FBQSxhQUFBO0FBQ0UsSUFBQSxNQUFNLENBQUMsSUFBUCxDQUFZLHVHQUFaLENBQUEsQ0FBQTtBQUNBLFdBQU8sTUFBUCxDQUZGO0dBMUNBO0FBQUEsU0ErQ29DLE9BQW5DLE9BQVEsaUJBQUEsV0FBVyxtQkFBQSxXQS9DcEIsQ0FBQTtBQUFBLEVBZ0RBLFdBQUEsR0FBYyxDQUFDLENBQUMsR0FBRixDQUFNLENBQUMsU0FBRCxFQUFZLFdBQVosRUFBeUIsY0FBekIsQ0FBTixFQUFnRCxTQUFDLENBQUQsR0FBQTtXQUFPLElBQUksQ0FBQyxRQUFMLENBQWMsQ0FBZCxFQUFQO0VBQUEsQ0FBaEQsQ0FoRGQsQ0FBQTtBQUFBLEVBa0RBLE1BQU0sQ0FBQyxPQUFPLENBQUMsWUFBZixHQUE4QixZQUFZLENBQUMsTUFBYixDQUFvQixXQUFwQixDQWxEOUIsQ0FBQTtBQUFBLEVBbURBLE1BQU0sQ0FBQyxPQUFPLENBQUMsU0FBZixHQUEyQixTQW5EM0IsQ0FBQTtBQUFBLEVBb0RBLE1BQU0sQ0FBQyxPQUFPLENBQUMsV0FBZixHQUE2QixXQXBEN0IsQ0FBQTtBQUFBLEVBcURBLE1BQU0sQ0FBQyxPQUFPLENBQUMsT0FBZixHQUF5QixNQUFNLENBQUMsT0FyRGhDLENBQUE7U0F1REEsT0F4RGlCO0FBQUEsQ0FqQ25CLENBQUEiLCJzb3VyY2VzQ29udGVudCI6WyJcInVzZSBzdHJpY3RcIlxuXG5fID0gcmVxdWlyZSBcImxvZGFzaFwiXG5wYXRoID0gcmVxdWlyZSAncGF0aCdcblxuZXhwb3J0cy5kZWZhdWx0cyA9IC0+XG4gIGZ1YnVtdmM6XG4gICAgdXNlUG9sbGluZzogdHJ1ZVxuICAgIGludGVydmFsOiA1MDBcbiAgICBiaW5hcnlJbnRlcnZhbDogMTAwMFxuICAgIGV4Y2x1ZGVQYXRoczogW1wiYmluXCIsIFwib2JqXCIsIC9eXFwuL11cbiAgICBjb252ZW50aW9uczogW11cblxuZXhwb3J0cy5wbGFjZWhvbGRlciA9IC0+XG4gIFwiXCJcIlxuICBcXHRcblxuICAjIGZ1YnVtdmM6XG4gICAgIyB1c2VQb2xsaW5nOiB0cnVlXG4gICAgIyBpbnRlcnZhbDogNTAwXG4gICAgIyBiaW5hcnlJbnRlcnZhbDogMTAwMFxuICAgICMgZXhjbHVkZVBhdGhzOiBbXCJiaW5cIiwgXCJvYmpcIiwgL15cXC4vXVxuICAgICMgY29udmVudGlvbnM6IFtcbiAgICAgICMgcHJvdmlkZSAwIG9yIG1vcmUgY29udmVudGlvbnNcbiAgICAgICMgeyBcbiAgICAgICAgIyBtYXRjaDogKGZpbGUsIGV4dCwgbG9nKSAtPlxuICAgICAgICAgICMgdHJ1ZSAjZmlsZW5hbWUgYW5kIGV4dGVuc2lvbiwgcmV0dXJuIHRydWUvZmFsc2UsXG4gICAgICAgICMgdHJhbnNmb3JtOiAoZmlsZSwgcGF0aCwgbG9nKSAtPlxuICAgICAgICAgICMgZmlsZSAjZmlsZW5hbWUgYW5kIHBhdGggbW9kdWxlIHRvIGRvIHBhdGguam9pbiwgZXRjXG4gICAgICAjIH1cbiAgICAjIF1cbiAgXCJcIlwiXG5cbmV4cG9ydHMudmFsaWRhdGUgPSAoY29uZmlnLCB2YWxpZGF0b3JzKSAtPlxuICBlcnJvcnMgPSBbXVxuICB7ZnVidW12Y30gPSBjb25maWdcbiAgdW5sZXNzIGZ1YnVtdmM/IGFuZCBfLmlzT2JqZWN0IGZ1YnVtdmNcbiAgICBlcnJvcnMucHVzaCBcImZ1YnVtdmMgY29uZmlnXCJcbiAgICByZXR1cm4gZXJyb3JzXG5cbiAge2V4Y2x1ZGVQYXRocywgY29udmVudGlvbnMsIHVzZVBvbGxpbmcsIGludGVydmFsLCBiaW5hcnlJbnRlcnZhbCwgYmFzZURpcn0gPSBmdWJ1bXZjXG5cbiAgdW5sZXNzICFiYXNlRGlyPyBvciAoYmFzZURpcj8gYW5kIHBhdGguZXhpc3RzU3luYyBiYXNlRGlyKVxuICAgIGVycm9ycy5wdXNoIFwiZnVidW12Yy5iYXNlRGlyXCJcbiAgICByZXR1cm4gZXJyb3JzXG5cbiAgdW5sZXNzIHVzZVBvbGxpbmc/IGFuZCBfLmlzQm9vbGVhbiB1c2VQb2xsaW5nXG4gICAgZXJyb3JzLnB1c2ggXCJmdWJ1bXZjLnVzZVBvbGxpbmdcIlxuICAgIHJldHVybiBlcnJvcnNcblxuICB1bmxlc3MgaW50ZXJ2YWw/IGFuZCBfLmlzTnVtYmVyIGludGVydmFsXG4gICAgZXJyb3JzLnB1c2ggXCJmdWJ1bXZjLmludGVydmFsXCJcbiAgICByZXR1cm4gZXJyb3JzXG5cbiAgdW5sZXNzIGJpbmFyeUludGVydmFsPyBhbmQgXy5pc051bWJlciBiaW5hcnlJbnRlcnZhbFxuICAgIGVycm9ycy5wdXNoIFwiZnVidW12Yy5iaW5hcnlJbnRlcnZhbFwiXG4gICAgcmV0dXJuIGVycm9yc1xuXG4gIHVubGVzcyBleGNsdWRlUGF0aHM/IGFuZCBfLmlzQXJyYXkgZXhjbHVkZVBhdGhzXG4gICAgZXJyb3JzLnB1c2ggXCJmdWJ1bXZjLmV4Y2x1ZGVQYXRoc1wiXG4gICAgcmV0dXJuIGVycm9yc1xuXG4gIGV4Y2x1ZGVQYXRoc09rID0gXy5hbGwgZXhjbHVkZVBhdGhzLCAoaXRlbSkgLT5cbiAgICBfLmlzU3RyaW5nKGl0ZW0pIG9yIF8uaXNSZWdFeHAoaXRlbSlcblxuICB1bmxlc3MgZXhjbHVkZVBhdGhzT2tcbiAgICBlcnJvcnMucHVzaCBcImZ1YnVtdmMuZXhjbHVkZVBhdGhzIGVudHJpZXMgbXVzdCBiZSBlaXRoZXIgc3RyaW5ncyBvciByZWdleGVzXCJcbiAgICByZXR1cm4gZXJyb3JzXG5cbiAgdW5sZXNzIGNvbnZlbnRpb25zPyBhbmQgXy5pc0FycmF5IGNvbnZlbnRpb25zXG4gICAgZXJyb3JzLnB1c2ggXCJmdWJ1bXZjLmNvbnZlbnRpb25zXCJcbiAgICByZXR1cm4gZXJyb3JzXG5cbiAgY29udmVudGlvbnNPayA9IF8uYWxsIGNvbnZlbnRpb25zLCAoaXRlbSkgLT5cbiAgICBfLmlzT2JqZWN0KGl0ZW0pIGFuZCBfLmFsbCBbXCJtYXRjaFwiLCBcInRyYW5zZm9ybVwiXSwgKGZ1bmMpIC0+IF8uaXNGdW5jdGlvbiBpdGVtW2Z1bmNdXG5cbiAgdW5sZXNzIGNvbnZlbnRpb25zT2tcbiAgICBlcnJvcnMucHVzaCBcImZ1YnVtdmMuY29udmVudGlvbnMgZW50cmllcyBtdXN0IGJlIG9iamVjdHMgd2l0aCBtYXRjaDogKGZpbGUsIGV4dCkgLT4gYW5kIHRyYW5zZm9ybTogKGZpbGUsIHBhdGgpIC0+XCJcbiAgICByZXR1cm4gZXJyb3JzXG5cbiAgI2F1dG8taW5jbHVkZSB0aGUgc291cmNlRGlyIGFuZCBjb21waWxlZERpciBpbnRvIGV4Y2x1ZGVQYXRocyBsaXN0XG4gIHt3YXRjaDoge3NvdXJjZURpciwgY29tcGlsZWREaXJ9fSA9IGNvbmZpZ1xuICBpZ25vcmVQYXRocyA9IF8ubWFwIFtzb3VyY2VEaXIsIGNvbXBpbGVkRGlyLCAnbm9kZV9tb2R1bGVzJ10sIChwKSAtPiBwYXRoLmJhc2VuYW1lIHBcblxuICBjb25maWcuZnVidW12Yy5leGNsdWRlUGF0aHMgPSBleGNsdWRlUGF0aHMuY29uY2F0IGlnbm9yZVBhdGhzXG4gIGNvbmZpZy5mdWJ1bXZjLnNvdXJjZURpciA9IHNvdXJjZURpclxuICBjb25maWcuZnVidW12Yy5jb21waWxlZERpciA9IGNvbXBpbGVkRGlyXG4gIGNvbmZpZy5mdWJ1bXZjLmlzQnVpbGQgPSBjb25maWcuaXNCdWlsZFxuXG4gIGVycm9yc1xuIl19
