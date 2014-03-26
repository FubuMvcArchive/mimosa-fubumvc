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

startWatching = (from, {numberOfFiles, adds, changes, unlinks, errors}, cb) ->
  fixPath = withoutFromPath from

  fromSource = (obs) ->
    obs.merge(errors).map fixPath

  initialCopy = fromSource(adds)
    .take(numberOfFiles)

  initialCopy.subscribe(
    (f) -> copyFile f
    (e) ->
      log "warn", "File watching error: #{e}"
      cb() if cb
    () ->
      ongoingCopy = fromSource(adds.merge changes)
      ongoingCopy.subscribe(
        (f) -> copyFile f
        (e) ->
          log "warn", "File watching error: #{e}"
      )
      cb() if cb
  )

  deletes = fromSource(unlinks)

  deletes.subscribe(
    (f) -> deleteFile f
    (e) ->
      log "error", "error deleting [[ #{e} ]]"
  )

copyFile = (file) ->
  fs.readFile file, (err, data) ->
    if err
      log "error", "Error reading file [[ #{file} ]], #{err}"
      return

    #TODO: conventions for where to put files
    outFile = file
    dirname = path.dirname outFile
    unless fs.existsSync dirname
      wrench.mkdirSyncRecursive dirname, 0o0777

    fs.writeFile outFile, data, (err) ->
      if err
        log "error", "Error reading file [[ #{file} ]], #{err}"
      else
        log "info", "File copied to destination [[ #{outFile} ]]."

deleteFile = (file) ->
  #TODO: reverse conventions for how to get path back
  outFile = file
  fs.exists outFile, (exists) ->
    if exists
      fs.unlink outFile, (err) ->
        if err
          log "error", "Error deleting file [[ #{outFile} ]], #{err}"
        else
          log "info", "File [[ #{outFile} ]] deleted."

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
  extensions = mimosaConfig?.extensions?.copy || []
  excludes = mimosaConfig?.fubumvc?.excludePaths || []
  isBuild = mimosaConfig?.isBuild || true

  log "debug", "importing assets"
  log "debug", "allowed extensions [[ #{extensions} ]]"
  log "debug", "excludes [[ #{excludes} ]]"

  fileWatcher = prepareFileWatcher cwd, extensions, excludes, isBuild
  startWatching cwd, fileWatcher, next
  #TODO: gather sources
  #.links, will use parseXml for this
  #fubu-content
  #source dir (including content)

cleanAssets = (mimosaConfig, options, next) ->
  next()

module.exports = {importAssets, cleanAssets}
