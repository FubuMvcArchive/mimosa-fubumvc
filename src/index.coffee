"use strict"

config = require './config'
fubuImport = require './fubu-import'
scaffolding = require './scaffolding'

registration = (mimosaConfig, register) ->
  register ['preBuild'], 'init', fubuImport.importAssets
  register ['postClean'], 'init', fubuImport.cleanAssets

registerCommand = (program, retrieveConfig) ->
  program
    .command('fubu:init')
    .description("bower.json and mimosa-config, 'coffee' flag for coffee")
    .action (args) ->
      scaffolding.setupFileSystem args
  program
    .command('fubu:reset')
    .description("rm -rf on assets and public then runs fubu:init")
    .action (args) ->
      scaffolding.resetFileSystem args

module.exports =
  registration:    registration
  registerCommand: registerCommand
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate
