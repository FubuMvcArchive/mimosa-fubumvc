rewirez = require "./rewirez"
chai = require "chai"
expect = chai.expect
_ = require "lodash"
path = require 'path'
scaffolding = rewirez "../lib/scaffolding.js"
scaffolding.__set__ "log", () ->

describe "initFiles", ->
  initFiles = scaffolding.__get__ "initFiles"

  writesFiles = (output, flags) ->
    writtenFiles = []
    fs =
      existsSync: (fileName) ->
        false
      writeFileSync: (fileName) -> writtenFiles.push fileName
    undo = scaffolding.__tempSet__ {fs}
    initFiles(flags)
    expect(writtenFiles).to.eql output
    undo()

  it "writes files", ->
    writesFiles ["bower.json", "mimosa-config.js"]

  it "uses .coffee extension for files when coffee flag is passed", ->
    writesFiles ["bower.json", "mimosa-config.coffee"], "coffee"

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
