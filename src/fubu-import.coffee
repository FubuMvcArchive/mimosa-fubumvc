"use strict"

fs = require 'fs'
path = require 'path'
watch = require 'chokidar'
wrench = require 'wrench'
logger = require 'logmimosa'
_ = require 'lodash'
Bliss = require 'bliss'
bliss = new Bliss
  ext: ".bliss"
  cacheEnabled: false,
  context: {}

importAssets = (mimosaConfig, options, next) ->
  next()

cleanAssets = (mimosaConfig, options, next) ->
  next()

relativeToThisFile = (filePath, dirname) ->
  dirname ?= __dirname
  path.join dirname, filePath

makeOptions = ->
  options =
    name: path.basename __dirname

initFiles = (flags = false) ->
  useCoffee = flags == "-c"
  options = makeOptions()
  ext = if useCoffee then "coffee" else "js"
  files = ["bower.json", "mimosa-config.#{ext}"]
  contents = _.chain files
    .map (f) -> relativeToThisFile "../fubu-import-templates/#{f}"
    .map (f) -> bliss.render f, options
    .map (f) -> f.trim()
    .value()
  fileWithContents = _.zip(files, contents)

  copyContents pair for pair in fileWithContents

copyContents = (pair) ->
  [fileName, contents] = pair
  unless fs.existsSync fileName
    logger.info "creating #{fileName}"
    fs.writeFileSync fileName, contents

registerCommand = (program, retrieveConfig) ->
  program
    .command('fubu:init')
    .description("scaffolds initial mimosa files, use -c for coffeescript")
    .action (opts)->
      initFiles(opts)

module.exports = {importAssets, cleanAssets, registerCommand}