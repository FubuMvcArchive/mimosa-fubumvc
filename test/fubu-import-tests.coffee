rewire = require("rewire")
chai = require("chai")
fubuImport = rewire("../lib/fubu-import.js")
expect = chai.expect
_ = require("lodash")
path = require 'path'
Rx = require "rx"

describe "fubu-import module", ->
  describe 'exports', ->
    rawFubuImport = require ("../lib/fubu-import.js")
    functions = ["importAssets", "cleanAssets", "setupFileSystem"]
    ensureIsFunction = (functionName) ->
      it "should export #{functionName}", ->
        expect(typeof rawFubuImport[functionName]).to.equal("function")

    ensureIsFunction functionName for functionName in functions

    it "should not export anything else", ->
      #rewire puts extra properties on the module that won't be there when its 'required'
      _.each rawFubuImport, (value, key) ->
        expect(_.contains functions, key).to.equal true

describe "relative paths", ->
  relativeToThisFile = fubuImport.__get__ "relativeToThisFile"
  it "can be provided by directory", ->
    sep = path.sep
    fakeDirname = "path#{sep}to#{sep}file"
    fileName = "test.txt"
    expect(relativeToThisFile fileName, fakeDirname).to.equal "#{fakeDirname}#{sep}#{fileName}"

describe "initFiles", ->
  initFiles = fubuImport.__get__ "initFiles"

  writesFiles = (output, flags) ->
    writtenFiles = []
    fs =
      existsSync: (fileName) ->
        false
      writeFileSync: (fileName) -> writtenFiles.push fileName
    fubuImport.__set__ {fs}
    initFiles(flags)
    expect(writtenFiles).to.eql output

  it "writes files", ->
    writesFiles ["bower.json", "mimosa-config.js"]

  it "uses .coffee extension for files when coffee flag is passed", ->
    writesFiles ["bower.json", "mimosa-config.coffee"], "coffee"

  it "only writes files if they don't exist already", ->
    fs =
      existsSync: (fileName) ->
        true
      writeFileSync: (args) -> chai.assert.fail(null, null, "should not write files")
    fubuImport.__set__ {fs}
    initFiles()

describe "makeFolders", ->
  makeFolders = fubuImport.__get__ "makeFolders"
  createdFolders = []
  mkdirp =
    sync: (fileName) ->
      createdFolders.push fileName

  it "creates assets/{scripts,styles} and public folder for you", ->
    fubuImport.__set__ {mkdirp}
    makeFolders()
    expect(createdFolders).to.eql ['assets/scripts', 'assets/styles', 'public']

describe "parseXml", ->
  parseXml = fubuImport.__get__ "parseXml"
  fs =
    readFileSync: (fileName) ->
      "<tag><numbers>one</numbers><numbers>two</numbers></tag>"

  it "can produce javascript object from xml", ->
    fubuImport.__set__ {fs}
    numbers = ["one","two"]
    output = parseXml 'test.xml'
    expect(output).to.have.deep.property("tag.numbers[0]", 'one')
    expect(output).to.have.deep.property("tag.numbers[1]", 'two')

describe "findSourceFiles", ->
  findSourceFiles = fubuImport.__get__ "findSourceFiles"
  fs =
    statSync: (file) ->
      isFile: -> true

  files = -> #empty for now, set by individual tests

  wrench =
    readdirSyncRecursive: (dir) -> files()

  it "ignores anything at the root", ->
    expected = [
      "1.js",
      "bower.json",
      "mimosa.config.js",
      "mimosa.config.coffee",
    ]
    files = -> expected
    fubuImport.__set__ {fs, wrench}
    result = findSourceFiles ".", ["js", "json", "coffee"], [] #empty excludes
    expect(result).to.eql []

  it "finds only the files that match extensions", ->
    expected = [
      (path.join "one", "2.js"),
      (path.join "one", "2.less"),
      (path.join "one", "two", "3.sass"),
    ]
    files = ->
      expected.concat [
       ".links",
       (path.join "one", "2.txt"),
       (path.join "one", "two", "3.doc"),
      ]
    fubuImport.__set__ {fs, wrench}
    result = findSourceFiles ".", ["js", "less", "sass"], [] #empty excludes
    expect(result).to.eql expected

  it "doesn't pick up excluded things", ->
    files = ->
      [(path.join ".mimosa", "bower", "last-install.json"),
       (path.join ".anyfolder", "startingwith", "period", "test.js")
       (path.join "bin", "StructureMap.xml"),
       (path.join "obj", "Debug", "test.txt")
      ]
    fubuImport.__set__ {fs, wrench}
    excludes = ["bin", "obj", /^\./]
    result = findSourceFiles ".", ["json", "js", "xml", "txt"], excludes
    expect(result).to.eql []

describe "isExcludedByConfig", ->
  isExcludedByConfig = fubuImport.__get__ "isExcludedByConfig"
  excludes = ["bin", "obj", /^\./]

  it "returns true when a path matches a string exclude", ->
    result = isExcludedByConfig "bin/somefile.txt", excludes
    expect(result).to.equal true

  it "returns true when a path matches a regex exclude", ->
    result = isExcludedByConfig ".mimosa/somefile.txt", excludes
    expect(result).to.equal true

  it "returns false otherwise", ->
    result = isExcludedByConfig "other/folder/somefile.txt", excludes
    expect(result).to.equal false

#TODO:
describe "startCopying", ->
  startCopying = fubuImport.__get__ "startCopying"
  cwd = process.cwd()
  prepareFileWatcher = () ->
    numberOfFiles = 3
    adds = Rx.Observable.create (obs) ->
      obs.onNext path.join cwd, "mimosa-config.js"
      obs.onNext path.join cwd, "content/scripts/1.js"
      obs.onNext path.join cwd, "content/styles/1.less"
      return () -> ""
    changes = Rx.Observable.never()
    unlinks = Rx.Observable.never()
    errors = (Rx.Observable.create (obs) ->
      obs.onNext {message: "there was an error"}
      return () -> "")
        .selectMany (e) -> Rx.Observable.throw e

    {numberOfFiles, adds, changes, unlinks, errors}

  extensions = ["js", "coffee"]
  excludes = ["node_modules", /^\./]
  fubuImport.__set__ {prepareFileWatcher}

  it "does", (done) ->
    startCopying(cwd, extensions, excludes, done)

