rewirez = require "./rewirez"
chai = require "chai"
expect = chai.expect
_ = require "lodash"
path = require 'path'
scaffolding = rewirez "../lib/scaffolding.js"
scaffolding.__set__ "log", (->)

describe "initFiles", ->
  initFiles = scaffolding.__get__ "initFiles"

  writesFiles = (output, flags, baseDir) ->
    writtenFiles = []
    fs =
      existsSync: (fileName) ->
        false
      writeFileSync: (fileName) -> writtenFiles.push fileName
    undo = scaffolding.__tempSet__ {fs}
    initFiles(flags, baseDir)
    expect(writtenFiles).to.eql output
    undo()

  it "writes files", ->
    writesFiles ["bower.json", "mimosa-config.js", "assets/dont-delete-me.js"]

  it "uses .coffee extension for files when coffee flag is passed", ->
    writesFiles ["bower.json", "mimosa-config.coffee", "assets/dont-delete-me.js"], "coffee"

  it "writes files at a specific place given a baseDir", ->
    writesFiles ["test/bower.json", "test/mimosa-config.coffee", "test/assets/dont-delete-me.js"], "coffee", "test"

  it "only writes files if they don't exist already", ->
    fs =
      existsSync: (fileName) ->
        true
      writeFileSync: (args) -> chai.assert.fail(null, null, "should not write files")
    undo = scaffolding.__tempSet__ {fs}
    initFiles()
    undo()

describe "makeFolders", ->
  makeFolders = scaffolding.__get__ "makeFolders"
  createdFolders = []
  wrench = 
    mkdirSyncRecursive: (fileName) ->
      createdFolders.push fileName

  it "creates assets/{scripts,styles} and public folder for you", ->
    undo = scaffolding.__tempSet__ {wrench}
    makeFolders()
    expect(createdFolders).to.eql ['assets/scripts', 'assets/styles', 'public']
    undo()
    createdFolders = []

  it "creates assets/{scripts,styles} and public folder in the correct directory if provided", ->
    undo = scaffolding.__tempSet__ {wrench}
    makeFolders("test")
    expect(createdFolders).to.eql ['test/assets/scripts', 'test/assets/styles', 'test/public']
    undo()
    createdFolders = []
