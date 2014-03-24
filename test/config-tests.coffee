chai = require("chai")
expect = chai.expect
config = require("../lib/config.js")

describe "the config", ->
  it "errors if no fubumvc config section is provided", ->
    fakeConfig = {}
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc config"]

  it "errors if fubumvc config section is not an object", ->
    fakeConfig =
      fubumvc: "wtf"
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc config"]

  it "errors without excludePaths property", ->
    fakeConfig =
      fubumvc: {}
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.excludePaths"]

  it "errors if excludePaths property is not an array", ->
    fakeConfig =
      fubumvc:
        excludePaths: "wtf"
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.excludePaths"]

  it "errors if excludePaths property contains anything other than strings and regexes", ->
    fakeConfig =
      fubumvc:
        excludePaths: [1, "bin", /^$/]
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.excludePaths entries must be either strings or regexes"]

  it "includes the sourceDir and compiledDir from watch config to excludePaths", ->
    sourceDir = "assets"
    compiledDir = "public"
    excludePaths = ["obj", "bin", /^$/]
    fakeConfig =
      watch: {sourceDir, compiledDir}
      fubumvc: {excludePaths}
    expected = [].concat.apply excludePaths, [sourceDir, compiledDir]
    result = config.validate fakeConfig
    expect(result).to.eql []
    expect(fakeConfig.fubumvc.excludePaths).to.eql expected


