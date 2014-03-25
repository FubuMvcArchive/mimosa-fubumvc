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
  #TODO: include sensible default extensions (.coffee, etc) pull from config somehow?
  extensions = mimosaConfig.extensions.copy
  excludes = mimosaConfig.fubumvc.excludePaths
  isBuild = mimosaConfig.isBuild
  startCopying cwd, extensions, excludes, isBuild, next
  #TODO: gather sources
  #.links, will use parseXml for this
  #fubu-content
  #source dir (including content)

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

prepareFileWatcher = (from, extensions, excludes, isBuild) ->
  #TODO: no more sync calls
  files  = findSourceFiles from, extensions, excludes
  numberOfFiles  = files.length
  fixPath = (input) -> withoutFromPath input, from

  watchSettings =
    ignored: (file) ->
      isDirectory = fs.statSync(file).isDirectory()
      if isDirectory
        false
      else
        f = fixPath file
        not (shouldInclude f, extensions, excludes)
    pesistent: not isBuild
    usePolling: true
    interval: 500
    binaryInterval: 1000

  observableFor = (event) ->
    Rx.Observable.fromEvent watcher, event

  watcher = watch.watch from, watchSettings
  adds = observableFor "add"
  changes = observableFor "change"
  unlinks = observableFor "unlink"
  errors = (observableFor "error").selectMany (e) -> Rx.Observable.Throw e
  {numberOfFiles, adds, changes, unlinks, errors}

withoutFromPath = (input, fromPath) ->
  input.replace "#{fromPath}#{path.sep}", ''

startCopying = (from, extensions, excludes, isBuild, cb) ->
  logger.debug "starting copy from: #{from}"
  logger.debug "extensions: #{extensions}"
  logger.debug "excludes: #{excludes}"

  {numberOfFiles, adds, changes, unlinks, errors} =
    prepareFileWatcher from, extensions, excludes, isBuild

  fixPath = (input) -> withoutFromPath input, from

  fromSource = (obs) ->
    obs.merge(errors).map fixPath

  initialCopy = fromSource(adds)
    .take(numberOfFiles)

  initialCopy.subscribe(
    (f) ->
      logger.info "initial copy: #{f}"
    (e) ->
      logger.error "error with initial copy: #{e.message}"
      cb() if cb
    () ->
      logger.info "initial copy complete"
      ongoingCopy = fromSource(adds.merge changes)
      ongoingCopy.subscribe(
        (f) ->
          logger.info "copy: #{f}"
        (e) ->
          logger.debug "error: #{e}"
      )
      cb() if cb
  )

  deletes = fromSource(unlinks)

  deletes.subscribe(
    (f) ->
      logger.info "deleting: #{f}"
    (e) ->
      logger.error "error deleting: #{e}"
  )

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
    logger.info "creating #{fileName}"
    fs.writeFileSync fileName, contents

parseXml = (filePath) ->
  contents = fs.readFileSync filePath
  result = {}
  parseString contents, (err, output) ->
    result = output
  result

module.exports = {importAssets, cleanAssets, setupFileSystem}
