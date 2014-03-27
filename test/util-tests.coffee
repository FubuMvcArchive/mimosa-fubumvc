rewire = require "rewire"
chai = require "chai"
expect = chai.expect
_ = require "lodash"
path = require "path"

util = rewire "../lib/util.js"

describe "relative paths", ->
  relativeToThisFile = util.__get__ "relativeToThisFile"
  it "can be provided by directory", ->
    sep = path.sep
    fakeDirname = "path#{sep}to#{sep}file"
    fileName = "test.txt"
    expect(relativeToThisFile fileName, fakeDirname).to.equal "#{fakeDirname}#{sep}#{fileName}"
