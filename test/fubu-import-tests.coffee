rewirez = require "./rewirez"
chai = require "chai"
expect = chai.expect
_ = require "lodash"
path = require 'path'
Rx = require "rx"
fubuImport = rewirez "../lib/fubu-import.js"
fubuImport.__set__ "log", (->)
cwd = process.cwd()

describe "fubu-import module", ->
  describe 'exports', ->
    rawFubuImport = require ("../lib/fubu-import.js")
    functions = ["importAssets", "cleanAssets"]
    ensureIsFunction = (functionName) ->
      it "should export #{functionName}", ->
        expect(typeof rawFubuImport[functionName]).to.equal("function")

    ensureIsFunction functionName for functionName in functions

    it "should not export anything else", ->
      #rewire puts extra properties on the module that won't be there when its 'required'
      _.each rawFubuImport, (value, key) ->
        expect(_.contains functions, key).to.equal true

describe "parseXml", ->
  parseXml = fubuImport.__get__ "parseXml"
  content =
      """
      <links><include>..\bottle</include><include>..\bottle2</include></links>
      """

  it "can produce javascript object from xml", ->
    output = parseXml content
    expect(output).to.have.deep.property("links.include[0]", '..\bottle')
    expect(output).to.have.deep.property("links.include[1]", '..\bottle2')

describe "findBottles", ->
  findBottles = fubuImport.__get__ "findBottles"

  it "parses includes entries in .links file", ->
    fs =
      existsSync: () -> true
      readFileSync: () -> 
        """
        <links><include>..\bottle</include><include>..\bottle2</include></links>
        """
    undo = fubuImport.__tempSet__ {fs}
    bottles = findBottles cwd
    expect(bottles).to.eql ["..\bottle", "..\bottle2"]
    undo()

  it "returns an empty array if it can't find one", ->
    fs =
      existsSync: () -> false
    undo = fubuImport.__tempSet__ {fs}
    bottles = findBottles cwd
    expect(bottles).to.eql []
    undo()

describe "findSourceFiles", ->
  findSourceFiles = fubuImport.__get__ "findSourceFiles"
  fs =
    statSync: (file) ->
      isFile: -> file isnt "one"

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
    undo = fubuImport.__tempSet__ {fs, wrench}
    result = findSourceFiles ".", ["js", "json", "coffee"], [] #empty excludes
    expect(result).to.eql []
    undo()

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
    undo = fubuImport.__tempSet__ {fs, wrench}
    result = findSourceFiles ".", ["js", "less", "sass"], [] #empty excludes
    expect(result).to.eql expected
    undo()

  it "doesn't pick up excluded things", ->
    files = ->
      [(path.join ".mimosa", "bower", "last-install.json"),
       (path.join ".anyfolder", "startingwith", "period", "test.js")
       (path.join "bin", "StructureMap.xml"),
       (path.join "obj", "Debug", "test.txt")
      ]
    undo = fubuImport.__tempSet__ {fs, wrench}
    excludes = ["bin", "obj", /^\./]
    result = findSourceFiles ".", ["json", "js", "xml", "txt"], excludes
    expect(result).to.eql []
    undo()

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

describe "startWatching", ->
  startWatching = fubuImport.__get__ "startWatching"
  fullPath = (f) -> path.join cwd, f
  expected =  [
    "mimosa-config.js",
    path.join "content", "scripts", "1.js"
    path.join "content", "styles", "1.less"
  ]
  files = (fullPath file for file in expected)
  copiedFiles = []
  copyFile = (f) ->
    copiedFiles.push f
  options =
    sourceDir: ""
    conventions: []

  it "calls copyFile for each value pushed from adds collection up to numberOfFiles worth of files", (done) ->
    addsObservable = Rx.Observable.never()
    fileWatcher = do ->
      numberOfFiles = 3
      adds = Rx.Observable.create (obs) ->
        addsObservable = obs
      changes = Rx.Observable.never()
      unlinks = Rx.Observable.never()
      errors = Rx.Observable.never()

      {numberOfFiles, adds, changes, unlinks, errors}

    undo = fubuImport.__tempSet__ {copyFile}
    cb = () ->
      expect(copiedFiles).to.eql expected
      undo()
      done()
    startWatching cwd, fileWatcher, options, cb
    _.each files, (f) -> addsObservable.onNext(f)

  it "stops when an error event happens", (done) ->
    copiedFiles = []
    addsObservable = Rx.Observable.never()
    fileWatcher = do ->
      numberOfFiles = 3
      adds = Rx.Observable.create (obs) ->
        addsObservable = obs
      changes = Rx.Observable.never()
      unlinks = Rx.Observable.never()
      errors = Rx.Observable.throw {message: "error!"}

      {numberOfFiles, adds, changes, unlinks, errors}

    undo = fubuImport.__tempSet__ {copyFile}
    cb = () ->
      expect(copiedFiles).to.eql []
      undo()
      done()
    startWatching cwd, fileWatcher, options, cb
    addsObservable.onNext(files[0])
    addsObservable.onNext(files[1])

describe "transformPath", ->
  transformPath = fubuImport.__get__ "transformPath"
  sourceDir = "assets"
  testConvention =
    match: (path, ext) -> true
    transform: (path) -> path

  it "with no conventions, just prepends the sourceDir", ->
    conventions = []
    file =  "1.js"
    result = transformPath file, cwd, {sourceDir, conventions}
    expect(result).to.equal path.join sourceDir, file

  it "in order, conventions transform results will be passed through each other", ->
    firstConvention =
      match: (file, ext) -> true
      transform: (file) -> path.join "scripts", file
    secondConvention =
      match: (file, ext) -> true
      transform: (file) -> path.join "v1", file
    conventions = [firstConvention, secondConvention]
    file = "2.js"
    result = transformPath file, cwd, {sourceDir, conventions}
    expect(result).to.equal path.join sourceDir, "v1", "scripts", file

describe "buildExtensions", ->
  buildExtensions = fubuImport.__get__ "buildExtensions"

  it "builds list of acceptable extensions from mimosa config", ->
    copy = ['js', 'css', 'mp3']
    js = ['js', 'coffee']
    css = ['css', 'less']
    fakeConfig =
      watch: {sourceDir: "assets", compiledDir: "public"}
      fubumvc: {excludePaths: [], conventions: []}
      extensions: {copy, js, css}
    result = buildExtensions fakeConfig
    expect(result).to.eql ['js', 'css', 'mp3', 'less']


