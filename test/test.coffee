expect = require("chai").expect
module = require("../lib/index.js")

describe "the module", ->
  describe 'exports', ->
    it "should contain a registration function", ->
      expect(typeof module.registration).to.equal("function")
