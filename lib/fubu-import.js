"use strict";
var cleanAssets, files, fs, importAssets, logger, path, registerCommand, test, watch, wrench, _;

fs = require('fs');

path = require('path');

watch = require('chokidar');

wrench = require('wrench');

logger = require('logmimosa');

_ = require('lodash');

importAssets = function(mimosaConfig, options, next) {
  return next();
};

cleanAssets = function(mimosaConfig, options, next) {
  return next();
};

files = {
  "mimosa.config": function() {
    return "exports.config =\n  modules: [\n    \"copy\",\n    \"jshint\",\n    \"csslint\",\n    \"require\",\n    \"minify-js\",\n    \"minify-css\",\n    \"bower\",\n    \"mimosa-fubu\"\n  ]\n\n  watch:\n    sourceDir: \"assets\"\n    compiledDir: \"public\"\n    javascriptDir: \"scripts\"\n\n  vendor:\n    javascripts: \"scripts/vendor\"\n    stylesheets: \"styles/vendor\"";
  },
  "bower.json": function(name) {
    return "{\n  \"name\": \"" + name + "\",\n  \"dependencies\": {\n  }\n}";
  }
};

test = function() {
  return _.each(files, function(getContents, fileName) {
    if (!fs.existsSync(fileName)) {
      return fs.writeFileSync(fileName, getContents());
    }
  });
};

registerCommand = function(program, retrieveConfig) {
  return program.command('fubu:init').description("creates simple mimosa.config and bower.json for you, execute from within your mvcapp directory").action(function(opts) {
    logger.info("running command");
    return test();
  });
};

module.exports = {
  importAssets: importAssets,
  cleanAssets: cleanAssets,
  registerCommand: registerCommand
};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiYzpcXGhvbWVcXGdpdGh1YlxcbWltb3NhLWZ1YnVcXGxpYlxcZnVidS1pbXBvcnQuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJjOlxcaG9tZVxcZ2l0aHViXFxtaW1vc2EtZnVidVxcc3JjXFxmdWJ1LWltcG9ydC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUEsWUFBQSxDQUFBO0FBQUEsSUFBQSwyRkFBQTs7QUFBQSxFQUVBLEdBQUssT0FBQSxDQUFRLElBQVIsQ0FGTCxDQUFBOztBQUFBLElBR0EsR0FBTyxPQUFBLENBQVEsTUFBUixDQUhQLENBQUE7O0FBQUEsS0FJQSxHQUFRLE9BQUEsQ0FBUSxVQUFSLENBSlIsQ0FBQTs7QUFBQSxNQUtBLEdBQVMsT0FBQSxDQUFRLFFBQVIsQ0FMVCxDQUFBOztBQUFBLE1BTUEsR0FBUyxPQUFBLENBQVEsV0FBUixDQU5ULENBQUE7O0FBQUEsQ0FPQSxHQUFJLE9BQUEsQ0FBUSxRQUFSLENBUEosQ0FBQTs7QUFBQSxZQWFBLEdBQWUsU0FBQyxZQUFELEVBQWUsT0FBZixFQUF3QixJQUF4QixHQUFBO1NBQ2IsSUFBQSxDQUFBLEVBRGE7QUFBQSxDQWJmLENBQUE7O0FBQUEsV0FnQkEsR0FBYyxTQUFDLFlBQUQsRUFBZSxPQUFmLEVBQXdCLElBQXhCLEdBQUE7U0FDWixJQUFBLENBQUEsRUFEWTtBQUFBLENBaEJkLENBQUE7O0FBQUEsS0FtQkEsR0FDRTtBQUFBLEVBQUEsZUFBQSxFQUFpQixTQUFBLEdBQUE7V0FDZixrWEFEZTtFQUFBLENBQWpCO0FBQUEsRUF1QkEsWUFBQSxFQUFjLFNBQUMsSUFBRCxHQUFBO1dBQ1QsbUJBQUEsR0FFQSxJQUZBLEdBRU0scUNBSEc7RUFBQSxDQXZCZDtDQXBCRixDQUFBOztBQUFBLElBb0RBLEdBQU8sU0FBQSxHQUFBO1NBQ0wsQ0FBQyxDQUFDLElBQUYsQ0FBTyxLQUFQLEVBQWMsU0FBQyxXQUFELEVBQWMsUUFBZCxHQUFBO0FBQ1osSUFBQSxJQUFBLENBQUEsRUFBUyxDQUFDLFVBQUgsQ0FBYyxRQUFkLENBQVA7YUFDRSxFQUFFLENBQUMsYUFBSCxDQUFpQixRQUFqQixFQUEyQixXQUFBLENBQUEsQ0FBM0IsRUFERjtLQURZO0VBQUEsQ0FBZCxFQURLO0FBQUEsQ0FwRFAsQ0FBQTs7QUFBQSxlQXlEQSxHQUFrQixTQUFDLE9BQUQsRUFBVSxjQUFWLEdBQUE7U0FDaEIsT0FDRSxDQUFDLE9BREgsQ0FDVyxXQURYLENBRUUsQ0FBQyxXQUZILENBRWUsZ0dBRmYsQ0FHRSxDQUFDLE1BSEgsQ0FHVSxTQUFDLElBQUQsR0FBQTtBQUNOLElBQUEsTUFBTSxDQUFDLElBQVAsQ0FBWSxpQkFBWixDQUFBLENBQUE7V0FDQSxJQUFBLENBQUEsRUFGTTtFQUFBLENBSFYsRUFEZ0I7QUFBQSxDQXpEbEIsQ0FBQTs7QUFBQSxNQWlFTSxDQUFDLE9BQVAsR0FDRTtBQUFBLEVBQUEsWUFBQSxFQUFjLFlBQWQ7QUFBQSxFQUNBLFdBQUEsRUFBYSxXQURiO0FBQUEsRUFFQSxlQUFBLEVBQWlCLGVBRmpCO0NBbEVGLENBQUEiLCJzb3VyY2VzQ29udGVudCI6WyJcInVzZSBzdHJpY3RcIlxyXG5cclxuZnMgPSByZXF1aXJlICdmcydcclxucGF0aCA9IHJlcXVpcmUgJ3BhdGgnXHJcbndhdGNoID0gcmVxdWlyZSAnY2hva2lkYXInXHJcbndyZW5jaCA9IHJlcXVpcmUgJ3dyZW5jaCdcclxubG9nZ2VyID0gcmVxdWlyZSAnbG9nbWltb3NhJ1xyXG5fID0gcmVxdWlyZSAnbG9kYXNoJ1xyXG5cclxuI2NyZWF0ZSBuZWNlc3NhcnkgZmlsZXNcclxuI21pbW9zYS5jb25maWdcclxuI2Jvd2VyLmpzb25cclxuXHJcbmltcG9ydEFzc2V0cyA9IChtaW1vc2FDb25maWcsIG9wdGlvbnMsIG5leHQpIC0+XHJcbiAgbmV4dCgpXHJcblxyXG5jbGVhbkFzc2V0cyA9IChtaW1vc2FDb25maWcsIG9wdGlvbnMsIG5leHQpIC0+XHJcbiAgbmV4dCgpXHJcblxyXG5maWxlcyA9XHJcbiAgXCJtaW1vc2EuY29uZmlnXCI6IC0+XHJcbiAgICBcIlwiXCJcclxuICAgIGV4cG9ydHMuY29uZmlnID1cclxuICAgICAgbW9kdWxlczogW1xyXG4gICAgICAgIFwiY29weVwiLFxyXG4gICAgICAgIFwianNoaW50XCIsXHJcbiAgICAgICAgXCJjc3NsaW50XCIsXHJcbiAgICAgICAgXCJyZXF1aXJlXCIsXHJcbiAgICAgICAgXCJtaW5pZnktanNcIixcclxuICAgICAgICBcIm1pbmlmeS1jc3NcIixcclxuICAgICAgICBcImJvd2VyXCIsXHJcbiAgICAgICAgXCJtaW1vc2EtZnVidVwiXHJcbiAgICAgIF1cclxuXHJcbiAgICAgIHdhdGNoOlxyXG4gICAgICAgIHNvdXJjZURpcjogXCJhc3NldHNcIlxyXG4gICAgICAgIGNvbXBpbGVkRGlyOiBcInB1YmxpY1wiXHJcbiAgICAgICAgamF2YXNjcmlwdERpcjogXCJzY3JpcHRzXCJcclxuXHJcbiAgICAgIHZlbmRvcjpcclxuICAgICAgICBqYXZhc2NyaXB0czogXCJzY3JpcHRzL3ZlbmRvclwiXHJcbiAgICAgICAgc3R5bGVzaGVldHM6IFwic3R5bGVzL3ZlbmRvclwiXHJcbiAgICBcIlwiXCJcclxuICBcImJvd2VyLmpzb25cIjogKG5hbWUpIC0+XHJcbiAgICBcIlwiXCJcclxuICAgIHtcclxuICAgICAgXCJuYW1lXCI6IFwiI3tuYW1lfVwiLFxyXG4gICAgICBcImRlcGVuZGVuY2llc1wiOiB7XHJcbiAgICAgIH1cclxuICAgIH1cclxuICAgIFwiXCJcIlxyXG5cclxudGVzdCA9IC0+XHJcbiAgXy5lYWNoIGZpbGVzLCAoZ2V0Q29udGVudHMsIGZpbGVOYW1lKSAtPlxyXG4gICAgdW5sZXNzIGZzLmV4aXN0c1N5bmMgZmlsZU5hbWVcclxuICAgICAgZnMud3JpdGVGaWxlU3luYyBmaWxlTmFtZSwgZ2V0Q29udGVudHMoKVxyXG5cclxucmVnaXN0ZXJDb21tYW5kID0gKHByb2dyYW0sIHJldHJpZXZlQ29uZmlnKSAtPlxyXG4gIHByb2dyYW1cclxuICAgIC5jb21tYW5kKCdmdWJ1OmluaXQnKVxyXG4gICAgLmRlc2NyaXB0aW9uKFwiY3JlYXRlcyBzaW1wbGUgbWltb3NhLmNvbmZpZyBhbmQgYm93ZXIuanNvbiBmb3IgeW91LCBleGVjdXRlIGZyb20gd2l0aGluIHlvdXIgbXZjYXBwIGRpcmVjdG9yeVwiKVxyXG4gICAgLmFjdGlvbiAob3B0cyktPlxyXG4gICAgICBsb2dnZXIuaW5mbyBcInJ1bm5pbmcgY29tbWFuZFwiXHJcbiAgICAgIHRlc3QoKVxyXG5cclxubW9kdWxlLmV4cG9ydHMgPVxyXG4gIGltcG9ydEFzc2V0czogaW1wb3J0QXNzZXRzXHJcbiAgY2xlYW5Bc3NldHM6IGNsZWFuQXNzZXRzXHJcbiAgcmVnaXN0ZXJDb21tYW5kOiByZWdpc3RlckNvbW1hbmRcclxuIl19
