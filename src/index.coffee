"use strict"

config = require './config'
fubuImport = require './fubu-import'
logger = require 'logmimosa'

registration = (mimosaConfig, register) ->
  register ['preBuild'], 'init', fubuImport.importAssets
  register ['postClean'], 'init', fubuImport.cleanAssets

module.exports =
  registration:    registration
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate
  registerCommand: fubuImport.registerCommand
