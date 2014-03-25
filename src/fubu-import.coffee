"use strict"

fs = require 'fs'
path = require 'path'
watch = require 'chokidar'
wrench = require 'wrench'
logger = require 'logmimosa'
_ = require 'lodash'
mkdirp = require 'mkdirp'
parseString = require('xml2js').parseString
Bliss = require 'bliss'
bliss = new Bliss
  ext: ".bliss"
  cacheEnabled: false,
  context: {}
cwd = process.cwd()
Rx = require "rx"

importAssets = (mimosaConfig, options, next) ->
  extensions = mimosaConfig.extensions.copy
  excludes = mimosaConfig.fubumvc.excludePaths
  sourceFiles = findSourceFiles cwd, extensions, excludes
  logger.info sourceFiles
  #TODO: gather sources
  #.links, will use parseXml for this
  #fubu-content
  #source dir (including content)
  next()

cleanAssets = (mimosaConfig, options, next) ->
  next()

findSourceFiles = (from, extensions, excludes) ->
  wrench.readdirSyncRecursive(from)
    .filter (f) ->
      isIncluded = shouldInclude f, extensions, excludes
      isFile = fs.statSync(f).isFile()
      isIncluded and isFile

shouldInclude = (f, extensions, excludes) ->
  #TODO: only adds the . to you for extensions if its left off
  extensions = extensions.map (ext) -> ".#{ext}"
  atRoot = f.indexOf(path.sep) == -1
  matchesExtension = _.contains extensions, path.extname f
  excluded = isExcludedByConfig f, excludes
  matchesExtension and not excluded and not atRoot

prepareFileWatcher = (from, extensions, excludes) ->
  files  = findSourceFiles from, extensions, excludes
  numberOfFiles  = files.length

  watchSettings =
    ignored: (file) ->
      isDirectory = fs.statSync(file).isDirectory()
      if isDirectory
        false
      else
        not (shouldInclude file, extensions, excludes)
    pesistent: false
    usePolling: true
    interval: 500
    binaryInterval: 1000

  watcher = watch.watch from, watchSettings
  adds = Rx.Observable.fromEvent watcher, "add"
  changes = Rx.Observable.fromEvent watcher, "change"
  unlinks = Rx.Observable.fromEvent watcher, "unlink"
  errors = (Rx.Observable.fromEvent watcher, "error").selectMany (e) -> Rx.Observable.Throw e
  {numberOfFiles, adds, changes, unlinks, errors}

startCopying = (from, extensions, excludes, cb) ->
  {numberOfFiles, adds, changes, unlinks, errors} =
    prepareFileWatcher from, extensions, excludes

  withoutFromPath = (input) ->
    input.replace "#{from}#{path.sep}", ''

  initialCopy = adds
    .merge(errors)
    .take(numberOfFiles)
    .map withoutFromPath

  initialCopy.subscribe(
    (f) ->
      logger.info "onNext: #{f}"
    (e) ->
      logger.info "onError: #{e}"
      cb() if cb
    () ->
      logger.info "onCompleted"
      cb() if cb
  )

  ongoingCopy = adds
    .merge(changes)
    .merge(errors)
    .map withoutFromPath

  ongoingCopy.subscribe(
    (f) ->
      logger.info "onNext: #{f}"
    (e) ->
      logger.info "onError: #{e}"
    () ->
      logger.info "onCompleted"
  )

  #filesToDelete = unlinks
  #  .merge(errors)
  #  .map (f) -> path.basename f

excludeStrategies =
  string:
    identity: _.isString
    predicate: (ex, path) -> path.indexOf(ex) == 0
  regex:
    identity: _.isRegExp
    predicate: (ex, path) -> ex.test path

isExcludedByConfig = (path, excludes) ->
  ofType = (method) ->
    excludes.filter (f) -> method(f)

  _.any excludeStrategies, ({identity, predicate}) ->
    _.any (ofType identity), (ex) -> predicate ex, path

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
    name: path.basename cwd

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
  #avoid returning an array of nothing when using a comprehension as your last line
  #by using an explicit return
  return

copyContents = ([fileName, contents]) ->
  unless fs.existsSync fileName
    logger.info "creating #{fileName}"
    fs.writeFileSync fileName, contents

parseXml = (filePath) ->
  contents = fs.readFileSync filePath
  result = {}
  parseString contents, (err, output) ->
    result = output
  result

module.exports = {importAssets, cleanAssets, setupFileSystem}
