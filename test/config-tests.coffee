chai = require "chai"
_ = require "lodash"
expect = chai.expect
config = require("../lib/config.js")

describe "the config", ->
  defaults =
    usePolling: true
    interval: 500
    binaryInterval: 1000

  it "errors if no fubumvc config section is provided", ->
    fakeConfig = {}
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc config"]

  it "errors if fubumvc config section is not an object", ->
    fakeConfig =
      fubumvc: "wtf"
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc config"]

  it "errors without usePolling property", ->
    fakeConfig =
      fubumvc: {}
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.usePolling"]

  it "errors if usePolling property is not a boolean", ->
    fakeConfig =
      fubumvc: {usePolling: []}
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.usePolling"]

  it "errors without interval property", ->
    fakeConfig =
      fubumvc: {usePolling: true}
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.interval"]

  it "errors without binaryInterval property", ->
    fakeConfig =
      fubumvc: {usePolling: true, interval: 500}
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.binaryInterval"]

  it "errors without excludePaths property", ->
    fakeConfig =
      fubumvc: defaults
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.excludePaths"]

  it "errors if excludePaths property is not an array", ->
    badData =
      excludePaths: "wtf"
    fakeConfig =
      fubumvc: _.extend badData, defaults
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.excludePaths"]

  it "errors if excludePaths property contains anything other than strings and regexes", ->
    badData =
      excludePaths: [1, "bin", /^$/]
    fakeConfig =
      fubumvc: _.extend badData, defaults
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.excludePaths entries must be either strings or regexes"]

  it "error without conventions property", ->
    fakeConfig =
      fubumvc: _.extend {excludePaths: []}, defaults
    result = config.validate fakeConfig
    expect(result).to.eql ["fubumvc.conventions"]

  it "errors if conventions property is not an array", ->
    fakeConfig =
      fubumvc: _.extend {excludePaths: [], conventions: {}}, defaults
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
        fubumvc: _.extend {excludePaths: [], conventions: convention}, defaults
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
      fubumvc: _.extend {excludePaths, conventions}, defaults
      extensions:
        copy: []

    it "includes sourceDir and compiledDir from watch config and also 'node_modules' to excludePaths", ->
      expected = excludePaths.concat [sourceDir, compiledDir, 'node_modules']
      result = config.validate fakeConfig
      expect(result).to.eql []
      expect(fakeConfig.fubumvc.excludePaths).to.eql expected
