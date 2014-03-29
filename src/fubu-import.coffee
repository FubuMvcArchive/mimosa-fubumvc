"use strict"

{log} = require './util'
color = require('ansi-color').set
fs = require 'fs'
path = require 'path'
watch = require 'chokidar'
wrench = require 'wrench'
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

withoutPath = (fromPath) ->
  (input) -> input.replace "#{fromPath}#{path.sep}", ''

prepareFileWatcher = (from, extensions, excludes, isBuild) ->
  #TODO: no more sync calls
  files  = findSourceFiles from, extensions, excludes
  numberOfFiles  = files.length
  fixPath = withoutPath from

  watchSettings =
    ignored: (file) ->
      isFile = fs.statSync(file).isFile()
      f = fixPath file
      not (shouldInclude f, isFile, extensions, excludes)
    persistent: not isBuild
    usePolling: true
    interval: 500
    binaryInterval: 1000

  observableFor = (event) ->
    Rx.Observable.fromEvent watcher, event

  watcher = watch.watch from, watchSettings
  adds = observableFor "add"
  changes = observableFor "change"
  unlinks = observableFor "unlink"
  errors = (observableFor "error").selectMany (e) -> Rx.Observable.throw e
  {numberOfFiles, adds, changes, unlinks, errors}

startWatching = (
  from,
  {numberOfFiles, adds, changes, unlinks, errors},
  options,
  cb) ->

  fixPath = withoutPath from

  fromSource = (obs) ->
    obs.merge(errors).map fixPath

  initialCopy = fromSource(adds)
    .take(numberOfFiles)

  initialCopy.subscribe(
    (f) ->
      copyFile f, options
    (e) ->
      log "warn", "File watching error: #{e}"
      cb() if cb
    () ->
      ongoingCopy = fromSource(adds.merge changes)
      ongoingCopy.subscribe(
        (f) -> copyFile f, options
        (e) -> log "warn", "File watching error: #{e}"
      )
      cb() if cb
  )

  deletes = fromSource(unlinks)

  deletes.subscribe(
    (f) ->
      outFile = transformPath f, options
      deleteFile outFile
    (e) -> log "warn", "File watching errors: #{e}"
  )

copyFile = (file, options) ->
  fs.readFile file, (err, data) ->
    if err
      log "error", "Error reading file [[ #{file} ]], #{err}"
      return

    outFile = transformPath file, options

    dirname = path.dirname outFile
    unless fs.existsSync dirname
      wrench.mkdirSyncRecursive dirname, 0o0777

    fs.writeFile outFile, data, (err) ->
      if err
        log "error", "Error reading file [[ #{file} ]], #{err}"
      else
        log "success", "File copied to destination [[ #{outFile} ]]."

deleteFileSync = (file) ->
  if fs.existsSync file
    fs.unlinkSync file
    log "success", "File [[ #{file} ]] deleted."

deleteFile = (file) ->
  fs.exists file, (exists) ->
    if exists
      fs.unlink file, (err) ->
        if err
          log "error", "Error deleting file [[ #{file} ]], #{err}"
        else
          log "success", "File [[ #{file} ]] deleted."

deleteDirectory = (dir, cb) ->
  if fs.existsSync dir
    fs.rmdir dir, (err) ->
      if err?.code is not "ENOTEMPTY"
        log "error", "Unable to delete directory [[ #{dir} ]]"
        log "error", err
      else
        log "info", "Deleted empty directory [[ #{dir} ]]"
      cb() if cb
  else cb() if cb

transformPath = (file, {sourceDir, conventions}) ->
  result = _.reduce(conventions, (acc, {match, transform}) ->
    ext = path.extname acc
    if match acc, ext then transform acc, path else acc
  , file)
  path.join sourceDir, result

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

buildExtensions = (config) ->
  {copy, javascript, css} = config.extensions
  extensions = _.union copy, javascript, css

importAssets = (mimosaConfig, options, next) ->
  {excludePaths, sourceDir, compiledDir, isBuild, conventions} =
    mimosaConfig.fubumvc

  extensions = buildExtensions mimosaConfig

  log "debug", "importing assets"
  log "debug", "allowed extensions [[ #{extensions} ]]"
  log "debug", "excludePaths [[ #{excludePaths} ]]"

  fileWatcher = prepareFileWatcher cwd, extensions, excludePaths, isBuild
  startWatching cwd, fileWatcher, {sourceDir, conventions}, next
  #TODO: gather sources
  #.links, will use parseXml for this
  #

cleanAssets = (mimosaConfig, options, next) ->
  {extensions, excludePaths, sourceDir, compiledDir, isBuild, conventions} =
    mimosaConfig.fubumvc
  extensions = buildExtensions mimosaConfig
  options = {sourceDir, conventions}

  files  = findSourceFiles cwd, extensions, excludePaths
  outputFiles = _.map files, (f) -> transformPath f, options

  _.each outputFiles, (f) -> deleteFileSync f

  dirs = _ files
    .map (f) -> transformPath f, options
    .map (f) -> path.dirname f
    .sortBy "length"
    .reverse()
    .value()

  remainingDirs = [].concat dirs
  done = (dir) ->
    remainingDirs = _.without remainingDirs, dir
    if remainingDirs.length == 0
      next()

  _ dirs
    .map (dir) -> [dir, () -> done(dir)]
    .each ([dir, cb]) ->
      deleteDirectory dir, cb

module.exports = {importAssets, cleanAssets}
