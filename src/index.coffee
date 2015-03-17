"use strict"

config = require './config'
fubuImport = require './fubu-import'
scaffolding = require './scaffolding'

registration = (mimosaConfig, register) ->
  mimosaConfig.log["info"] "setting up fubumvc"
  scaffolding.setupFileSystemWithConfig mimosaConfig
  register ['preBuild'], 'init', (mimosaConfig, options, next) ->
    fubuImport.importAssets mimosaConfig, options, next
  register ['postClean'], 'init', fubuImport.cleanAssets

registerCommand = (program, logger, retrieveConfig) ->
  program
    .command('fubu:init')
    .description("bower.json and mimosa-config, 'coffee' flag for coffee")
    .action (args) ->
      scaffolding.setupFileSystem args, retrieveConfig
  program
    .command('fubu:reset')
    .description("rm -rf on assets and public then runs fubu:init")
    .action (args) ->
      scaffolding.resetFileSystem args, retrieveConfig

module.exports =
  registration:    registration
  registerCommand: registerCommand
  defaults:        config.defaults
  validate:        config.validate
