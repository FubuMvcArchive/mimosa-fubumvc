chai = require "chai"
_ = require "lodash"
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

  it "error without conventions property", ->
    fakeConfig =
      fubumvc:
        excludePaths: []
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.conventions"]

  it "errors if conventions property is not an array", ->
    fakeConfig =
      fubumvc:
        excludePaths: []
        conventions: {}
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.conventions"]

  describe "conventions property", ->
    wrongConventions = [
      [1,2,3],
      [1, 2, {match: (->), transform: (->) }],
      [{match: (->), transform: (->) }, {match: (->)}],
    ]
    _.each wrongConventions, (convention) ->
      fakeConfig =
        watch: {sourceDir: "source", compiledDir: "compiled"}
        fubumvc:
          excludePaths: []
          conventions: convention
      it "errors if it contains items that are not objects with a match and transform function", ->
        result = config.validate fakeConfig
        expect(result).to.eql ["fubumvc.conventions entries must be objects with match: (file, ext) -> and transform: (file, path) ->"]

  describe "config behavior", ->
    sourceDir = "assets"
    compiledDir = "public"
    conventions = []
    excludePaths = ["obj", "bin", /^$/]
    fakeConfig =
      watch: {sourceDir, compiledDir}
      fubumvc: {excludePaths, conventions}
      extensions:
        copy: []

    it "includes sourceDir and compiledDir from watch config and also 'node_modules' to excludePaths", ->
      expected = excludePaths.concat [sourceDir, compiledDir, 'node_modules']
      result = config.validate fakeConfig
      expect(result).to.eql []
      expect(fakeConfig.fubumvc.excludePaths).to.eql expected
