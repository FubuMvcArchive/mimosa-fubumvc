"use strict"
fs = require 'fs'
path = require 'path'
wrench = require 'wrench'
_ = require 'lodash'
{log, relativeToThisFile} = require './util'
Bliss = require 'bliss'
bliss = new Bliss
  ext: ".bliss"
  cacheEnabled: false,
  context: {}
cwd = process.cwd()

setupFileSystem = (args) ->
  makeFolders()
  initFiles(args)

makeFolders = ->
  folders = ['assets/scripts', 'assets/styles', 'public']
  _.each folders, (dir) ->
    unless fs.existsSync dir
      log "info", "creating #{dir}"
      wrench.mkdirSyncRecursive dir, 0o0777

initFiles = (flags = false) ->
  useCoffee = flags == "coffee"
  ext = if useCoffee then "coffee" else "js"
  files = ["bower.json", "mimosa-config.#{ext}"]
  viewModel =
    name: path.basename cwd
  contents = _ files
    .map (f) -> relativeToThisFile "../fubu-import-templates/#{f}"
    .map (f) -> bliss.render f, viewModel
    .map (f) -> f.trim()
    .value()
  fileWithContents = _.zip(files, contents)

  _.each fileWithContents, (pair) ->
    copyContents pair
  #avoid returning an array of nothing when using a comprehension as your last line
  #by using an explicit return
  return

copyContents = ([fileName, contents]) ->
  unless fs.existsSync fileName
    log "info", "creating #{fileName}"
    fs.writeFileSync fileName, contents

module.exports = {setupFileSystem}
