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
      expect(copiedFiles).to.eql files
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
    match: (file, ext) -> true
    transform: (file) -> file

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

describe "workingDir and setWorkingDir", ->
  workingDir = fubuImport.__get__ "workingDir"
  setWorkingDir = fubuImport.__get__ "setWorkingDir"
  it "uses the cwd for the working dir by default", ->
    expect(workingDir).to.eql cwd

  it "sets the workingDir to cwd if given a falsy value", ->
    setWorkingDir null
    workingDir = fubuImport.__get__ "workingDir"
    expect(workingDir).to.eql cwd

  it "sets the workingDir to a path if given", ->
    pathName = "some/path/"
    setWorkingDir pathName
    workingDir = fubuImport.__get__ "workingDir"
    expect(workingDir).to.eql pathName

describe "trackCompletion", ->
  trackCompletion = fubuImport.__get__ "trackCompletion"
  it "provides a function that you can call for each item in the initial list,
    after calling all of them it will call a final callback for you", ->
    calledCallback = false
    initial = [1,2,3]
    final = -> calledCallback = true
    finish = trackCompletion "test", initial, final
    _.each initial, (x) -> finish(x)

    expect(calledCallback).to.equal true

describe "clean", ->
  clean = fubuImport.__get__ "clean"
  target = cwd
  fakeDir = "fakeDir"
  nestedDir = path.join fakeDir, "nestedDir"
  files = _.map ["1.coffee", "2.coffee", "3.coffee"], (f) -> path.join fakeDir, f
  files = files.concat [path.join nestedDir, "4.coffee"]
  outputFiles = _.map files, (f) -> f.replace "coffee", "js"
  done = false
  deletedFiles = []
  deleteFileSync = (f) -> deletedFiles.push f
  deletedDirectories = []
  deleteDirectory = (dir, cb) ->
    deletedDirectories.push dir
    cb()

  test = (title, expectation) ->
    it title, ->
      done = false
      deletedFiles = []
      deletedDirectories = []
      undo = fubuImport.__tempSet__ {deleteFileSync, deleteDirectory}
      clean [target, files, outputFiles], () -> done = true
      expectation()
      undo()

  test "deletes all files in the outputFiles list", ->
    expect(deletedFiles).to.eql outputFiles

  test "deletes all directories in order of longest to shortest", ->
    expect(deletedDirectories).to.eql [nestedDir, fakeDir]

  test "calls the callback when its done", ->
    expect(done).to.equal true

  it "immediately calls the callback if there are no files to delete", ->
    done = false
    clean [target, [], []], () -> done = true
    expect(done).to.equal true

describe "getTargets", ->
  getTargets = fubuImport.__get__ "getTargets"
  mainDir = "src/mainProject"
  bottles = ["bottle1", "bottle2", "bottle3"]
  findBottles = (sourceDir) -> _.map bottles, (f) -> "../#{f}"
  fakePath =
    resolve: (first, second) -> path.join mainDir, second

  it "accepts a directory as a parameter and will return resolved paths to all bottles found plus the original directory itself", ->
    undo = fubuImport.__tempSet__ {findBottles: findBottles, path: fakePath}
    targets = getTargets mainDir
    undo()
    expected = _.map bottles, (f) -> path.join "src", f
    expect(targets).to.eql expected.concat [mainDir]
