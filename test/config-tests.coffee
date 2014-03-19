chai = require("chai")
expect = chai.expect
config = require("../lib/config.js")

describe "the config", ->
  it "is validated", ->
    fakeConfig =
      fubumvc: ""
    result = config.validate fakeConfig
    expect(result).to.eql []

