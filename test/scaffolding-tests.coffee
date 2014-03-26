rewire = require "rewire"
chai = require "chai"
expect = chai.expect
_ = require "lodash"
path = require 'path'
scaffolding = rewire "../lib/scaffolding.js"

describe "initFiles", ->
  initFiles = scaffolding.__get__ "initFiles"

  writesFiles = (output, flags) ->
    writtenFiles = []
    fs =
      existsSync: (fileName) ->
        false
      writeFileSync: (fileName) -> writtenFiles.push fileName
    scaffolding.__set__ {fs}
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
    scaffolding.__set__ {fs}
    initFiles()

describe "makeFolders", ->
  makeFolders = scaffolding.__get__ "makeFolders"
  createdFolders = []
  mkdirp =
    sync: (fileName) ->
      createdFolders.push fileName

  it "creates assets/{scripts,styles} and public folder for you", ->
    scaffolding.__set__ {mkdirp}
    makeFolders()
    expect(createdFolders).to.eql ['assets/scripts', 'assets/styles', 'public']
