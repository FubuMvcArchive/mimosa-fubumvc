"use strict";
var config, fubuImport, registerCommand, registration, scaffolding;

config = require('./config');

fubuImport = require('./fubu-import');

scaffolding = require('./scaffolding');

registration = function(mimosaConfig, register) {
  mimosaConfig.log["info"]("setting up fubumvc");
  scaffolding.setupFileSystemWithConfig(mimosaConfig);
  register(['preBuild'], 'init', function(mimosaConfig, options, next) {
    return fubuImport.importAssets(mimosaConfig, options, next);
  });
  return register(['postClean'], 'init', fubuImport.cleanAssets);
};

registerCommand = function(program, logger, retrieveConfig) {
  program.command('fubu:init').description("bower.json and mimosa-config, 'coffee' flag for coffee").action(function(args) {
    return scaffolding.setupFileSystem(args, retrieveConfig);
  });
  return program.command('fubu:reset').description("rm -rf on assets and public then runs fubu:init").action(function(args) {
    return scaffolding.resetFileSystem(args, retrieveConfig);
  });
};

module.exports = {
  registration: registration,
  registerCommand: registerCommand,
  defaults: config.defaults,
  validate: config.validate
};
