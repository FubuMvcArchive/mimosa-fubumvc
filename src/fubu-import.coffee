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
  #TODO: get excludes from config instead of hard coding
  excludes = ["bin", "obj", /^\./]
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
      matchesExtension = _.contains extensions, path.extname f
      isFile = fs.statSync(f).isFile()
      excluded = isExcluded f, excludes
      matchesExtension and isFile and not excluded

isExcluded = (path, excludes) ->
  excludeStrategies =
    string:
      identity: _.isString
      predicate: (ex) -> path.indexOf(ex) == 0
    regex:
      identity: _.isRegExp
      predicate: (ex) -> ex.test path
  ofType = (method) ->
    excludes.filter (f) -> method(f)

  _.any excludeStrategies, ({identity, predicate}) ->
    _.any (ofType identity), predicate

relativeToThisFile = (filePath, dirname) ->
  dirname ?= __dirname
  path.join dirname, filePath

setupFileSystem = (args) ->
  makeFolders()
  initFiles(args)

makeFolders = ->
  #TODO: read this from config settings instead of hard coding this
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

copyContents = (pair) ->
  [fileName, contents] = pair
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
