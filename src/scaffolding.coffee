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

setupFileSystem = (args, retrieveConfig) ->
  retrieveConfig({ buildFirst: false }, (config) ->
    setupFileSystemWithConfig config, args
  )

setupFileSystemWithConfig = (config, args) ->
  baseDir = if config.fubumvc then config.fubumvc.baseDir else cwd
  makeFolders(baseDir)
  initFiles(args, baseDir)

resetFileSystem = (args, retrieveConfig) ->
  retrieveConfig({ buildFirst: false }, (config) ->
    baseDir = if config.fubumvc then config.fubumvc.baseDir else cwd
    deleteFolders(baseDir)
    setupFileSystem args, retrieveConfig
  )

makeFolders = (baseDir = "")->
  folders = ['assets/scripts', 'assets/styles', 'public']
  _.each folders, (dir) ->
    unless fs.existsSync dir
      target = path.join(baseDir, dir)
      log "info", "creating #{target}"
      wrench.mkdirSyncRecursive target, 0o0777

removeAllFilesFromDirectory = (folder, keep) ->
  fs.readdirSync(folder).forEach (file) ->
    targetFile = path.join(folder, file)
    isDir = fs.lstatSync(targetFile).isDirectory()
    if file is keep
      if isDir then removeAllFilesFromDirectory targetFile
      return
    try
      if isDir then wrench.rmdirSyncRecursive(targetFile) else
        if (/\.gitignore/.test targetFile)
          return
        fs.unlinkSync(targetFile)
        log "success", "deleted #{targetFile}"
    catch err
      log("error", err)

deleteFolders = (baseDir = "")->
  folders = ['assets', 'public']
  _.each folders, (dir) ->
    target = path.join(baseDir, dir)
    removeAllFilesFromDirectory target, "scripts"

filesAtBase = (baseDir, files) ->
  _.map files, (f)-> path.join(baseDir, f)

initFiles = (flags = false, baseDir = "") ->
  useCoffee = flags == "coffee"
  ext = if useCoffee then "coffee" else "js"
  files = ["bower.json", "mimosa-config.#{ext}", "assets/dont-delete-me.js"]
  viewModel =
    name: path.basename cwd
  contents = _ files
    .map (f) -> relativeToThisFile path.join("../fubu-import-templates/", f)
    .map (f) -> bliss.render f, viewModel
    .map (f) -> f.trim()
    .value()
  fileWithContents = _.zip(filesAtBase(baseDir, files), contents)

  _.each fileWithContents, (pair) ->
    copyContents pair
  #avoid returning an array of nothing when using a comprehension as your last line
  #by using an explicit return
  return

copyContents = ([fileName, contents]) ->
  unless fs.existsSync fileName
    log "info", "creating #{fileName}"
    fs.writeFileSync fileName, contents

module.exports = {setupFileSystem, resetFileSystem, setupFileSystemWithConfig}
