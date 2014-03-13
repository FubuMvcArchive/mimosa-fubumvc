"use strict"

fs = require 'fs'
path = require 'path'
watch = require 'chokidar'
wrench = require 'wrench'
logger = require 'logmimosa'
_ = require 'lodash'

#create necessary files
#mimosa.config
#bower.json

importAssets = (mimosaConfig, options, next) ->
  next()

cleanAssets = (mimosaConfig, options, next) ->
  next()

files =
  "mimosa.config": ->
    """
    exports.config =
      modules: [
        "copy",
        "jshint",
        "csslint",
        "require",
        "minify-js",
        "minify-css",
        "bower",
        "mimosa-fubu"
      ]

      watch:
        sourceDir: "assets"
        compiledDir: "public"
        javascriptDir: "scripts"

      vendor:
        javascripts: "scripts/vendor"
        stylesheets: "styles/vendor"
    """
  "bower.json": (name) ->
    """
    {
      "name": "#{name}",
      "dependencies": {
      }
    }
    """

test = ->
  _.each files, (getContents, fileName) ->
    unless fs.existsSync fileName
      fs.writeFileSync fileName, getContents()

registerCommand = (program, retrieveConfig) ->
  program
    .command('fubu:init')
    .description("creates simple mimosa.config and bower.json for you, execute from within your mvcapp directory")
    .action (opts)->
      logger.info "running command"
      test()

module.exports =
  importAssets: importAssets
  cleanAssets: cleanAssets
  registerCommand: registerCommand
