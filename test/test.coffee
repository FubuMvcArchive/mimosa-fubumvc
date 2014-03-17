rewire = require("rewire")
chai = require("chai")
fubuImport = rewire("../lib/fubu-import.js")
chai.should()
_ = require("lodash")

describe "fubu-import", ->
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

describe "can get relative paths", ->
  relativeToThisFile = fubuImport.__get__ "relativeToThisFile"
  it "to the directory provided", ->
    fakeDirname = "path\\to\\file"
    fileName = "test.txt"
    (relativeToThisFile fileName, fakeDirname).should.equal "#{fakeDirname}\\#{fileName}"


describe "fubu:init command", ->
  #fsMock =

  #fubuImport.__set__ {fsMock}

  describe "should create files", ->
    it "but only writes files if they don't exist already", ->
      initFiles = fubuImport.__get__ "initFiles"
      initFiles()

