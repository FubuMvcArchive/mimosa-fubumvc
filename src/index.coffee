"use strict"

config = require './config'
fubuImport = require './fubu-import'
scaffolding = require './scaffolding'
logger = require 'logmimosa'

registration = (mimosaConfig, register) ->
  register ['preBuild'], 'init', fubuImport.importAssets
  register ['postClean'], 'init', fubuImport.cleanAssets

registerCommand = (program, retrieveConfig) ->
  program
    .command('fubu:init')
    .description("bower.json and mimosa-config, 'coffee' flag for coffee")
    .action (args) ->
      scaffolding.setupFileSystem args

module.exports =
  registration:    registration
  registerCommand: registerCommand
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate
