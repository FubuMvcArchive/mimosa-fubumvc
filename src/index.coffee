"use strict"

config = require './config'
fubuImport = require './fubu-import'
logger = require 'logmimosa'

registration = (mimosaConfig, register) ->
  register ['preBuild'], 'init', fubuImport.importAssets
  register ['postClean'], 'init', fubuImport.cleanAssets

registerCommand = (program, retrieveConfig) ->
  program
    .command('fubu:init')
    .description("scaffolds initial mimosa files, use -c for coffeescript")
    .action (args) ->
      fubuImport.setupFileSystem args

module.exports =
  registration:    registration
  registerCommand: registerCommand
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate
