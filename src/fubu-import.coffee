"use strict"

fs = require 'fs'
path = require 'path'
watch = require 'chokidar'
wrench = require 'wrench'
logger = require 'logmimosa'
_ = require 'lodash'
mkdirp = require 'mkdirp'
Bliss = require 'bliss'
bliss = new Bliss
  ext: ".bliss"
  cacheEnabled: false,
  context: {}

importAssets = (mimosaConfig, options, next) ->
  extensions = mimosaConfig.extensions.copy
  #TODO: gather sources
  #.links
  #fubu-content
  #source dir (including content)
  next()

cleanAssets = (mimosaConfig, options, next) ->
  next()

relativeToThisFile = (filePath, dirname) ->
  dirname ?= __dirname
  path.join dirname, filePath

setupFileSystem = (args) ->
  makeFolders()
  initFiles(args)

makeFolders = ->
  folders = ['assets/scripts', 'assets/styles', 'public']
  _.each folders, (dir) ->
    logger.info "making sure #{dir} exists"
    mkdirp.sync dir, (err) ->
      logger.error(err)

makeOptions = ->
  options =
    name: path.basename process.cwd()

initFiles = (flags = false) ->
  useCoffee = flags == "coffee"
  options = makeOptions()
  ext = if useCoffee then "coffee" else "js"
  files = ["bower.json", "mimosa-config.#{ext}"]
  contents = _ files
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

parseXml = (filePath) ->
  ""

module.exports = {importAssets, cleanAssets, setupFileSystem}
