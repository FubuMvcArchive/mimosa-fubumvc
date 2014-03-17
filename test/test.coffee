rewire = require("rewire")
chai = require("chai")
fubuImport = rewire("../lib/fubu-import.js")
chai.should()
_ = require("lodash")

describe "fubu-import module", ->
  rawFubuImport = require ("../lib/fubu-import.js")
  describe 'exports', ->
    functions = ["importAssets", "cleanAssets", "registerCommand"]
    ensureIsFunction = (functionName) ->
      it "should export #{functionName}", ->
        rawFubuImport.should.have.property
        (typeof rawFubuImport[functionName]).should.equal("function")

    ensureIsFunction functionName for functionName in functions

    it "should not export anything else", ->
      #rewire puts extra properties on the module that won't be there when its 'required'
      _.each rawFubuImport, (value, key) ->
        (_.contains functions, key).should.equal true

describe "relative paths", ->
  relativeToThisFile = fubuImport.__get__ "relativeToThisFile"
  it "can be provided by directory", ->
    fakeDirname = "path\\to\\file"
    fileName = "test.txt"
    (relativeToThisFile fileName, fakeDirname).should.equal "#{fakeDirname}\\#{fileName}"

describe "fubu:init command", ->
  initFiles = fubuImport.__get__ "initFiles"

  it "writes files", ->
    writtenFiles = []
    fsMock =
      existsSync: (fileName) ->
        false
      writeFileSync: (fileName) -> writtenFiles.push fileName
    fubuImport.__set__ "fs", fsMock
    initFiles()
    writtenFiles.should.eql ["bower.json", "mimosa-config.js"]

  it "only writes files if they don't exist already", ->
    fsMock =
      existsSync: (fileName) ->
        true
      writeFileSync: (args) -> chai.assert.fail(null, null, "should not write files")
    fubuImport.__set__ "fs", fsMock
    initFiles()


