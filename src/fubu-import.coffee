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

importAssets = (mimosaConfig, options, next) ->
  extensions = mimosaConfig.extensions.copy
  excludes = mimosaConfig.fubumvc.excludePaths
  sourceFiles = findSourceFiles extensions, excludes
  logger.info sourceFiles
  #TODO: gather sources
  #.links, will use parseXml for this
  #fubu-content
  #source dir (including content)
  next()

cleanAssets = (mimosaConfig, options, next) ->
  next()

findSourceFiles = (extensions, excludes) ->
  extensions = extensions.map (ext) -> ".#{ext}"
  wrench.readdirSyncRecursive(cwd)
    .filter (f) ->
      atRoot = f.indexOf(path.sep) == -1
      matchesExtension = _.contains extensions, path.extname f
      isFile = fs.statSync(f).isFile()
      excluded = isExcluded f, excludes
      matchesExtension and isFile and not excluded and not atRoot

excludeStrategies =
  string:
    identity: _.isString
    predicate: (ex, path) -> path.indexOf(ex) == 0
  regex:
    identity: _.isRegExp
    predicate: (ex, path) -> ex.test path

isExcluded = (path, excludes) ->
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
