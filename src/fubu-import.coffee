"use strict"

{log} = require './util'
color = require('ansi-color').set
fs = require 'fs'
path = require 'path'
watch = require 'chokidar'
wrench = require 'wrench'
logger = require 'logmimosa'
_ = require 'lodash'
parseString = require('xml2js').parseString
cwd = process.cwd()
Rx = require "rx"

findSourceFiles = (from, extensions, excludes) ->
  wrench.readdirSyncRecursive(from)
    .filter (f) ->
      isFile = fs.statSync(f).isFile()
      isIncluded = shouldInclude f, isFile, extensions, excludes
      isIncluded and isFile

shouldInclude = (f, isFile, extensions, excludes) ->
  #TODO: only adds the . to you for extensions if its left off
  extensions = extensions.map (ext) -> ".#{ext}"
  ext = path.extname f
  matchesExtension = not isFile or _.contains extensions, ext
  atRoot = isFile and f.indexOf(path.sep) == -1
  excluded = isExcludedByConfig f, excludes
  matchesExtension and not excluded and not atRoot

withoutFromPath = (fromPath) ->
  (input) -> input.replace "#{fromPath}#{path.sep}", ''

prepareFileWatcher = (from, extensions, excludes, isBuild) ->
  #TODO: no more sync calls
  files  = findSourceFiles from, extensions, excludes
  numberOfFiles  = files.length
  fixPath = withoutFromPath from

  watchSettings =
    ignored: (file) ->
      isFile = fs.statSync(file).isFile()
      f = fixPath file
      not (shouldInclude f, isFile, extensions, excludes)
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

startCopying = (from, extensions, excludes, isBuild, cb) ->
  log "debug", "starting copy from [[ #{from} ]]"
  log "debug", "allowed extensions [[ #{extensions} ]]"
  log "debug", "excludes [[ #{excludes} ]]"

  {numberOfFiles, adds, changes, unlinks, errors} =
    prepareFileWatcher from, extensions, excludes, isBuild

  fixPath = withoutFromPath from

  fromSource = (obs) ->
    obs.merge(errors).map fixPath

  initialCopy = fromSource(adds)
    .take(numberOfFiles)

  logSuccess = (f) ->
      log "success", "#{color("copy", "green")} [[ #{f} ]]"
  logError = (e) ->
      log "error", "error copying [[ #{e} ]]"

  initialCopy.subscribe(
    (f) ->
      logSuccess f
    (e) ->
      logError e
      cb() if cb
    () ->
      ongoingCopy = fromSource(adds.merge changes)
      ongoingCopy.subscribe(
        (f) ->
          logSuccess f
        (e) ->
          logError e
      )
      cb() if cb
  )

  deletes = fromSource(unlinks)

  deletes.subscribe(
    (f) ->
      log "success", "#{color("deleting", "red")} [[ #{f} ]]"
    (e) ->
      log "error", "error deleting [[ #{e} ]]"
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

parseXml = (filePath) ->
  contents = fs.readFileSync filePath
  result = {}
  parseString contents, (err, output) ->
    result = output
  result

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

module.exports = {importAssets, cleanAssets}
