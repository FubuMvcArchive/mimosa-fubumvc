rewire = require("rewire")
chai = require("chai")
module = rewire("../lib/fubu-import.js")
chai.should()

describe "the module", ->
  describe 'exports', ->
    it "should contain importAssets function", ->
      (typeof module.importAssets).should.equal("function")
    it "should contain cleanAssets function", ->
      (typeof module.importAssets).should.equal("function")
