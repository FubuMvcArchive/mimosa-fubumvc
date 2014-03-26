"use strict"
logger = require 'logmimosa'
path = require 'path'

log = (level, statement) ->
  logger[level] "fubumvc: #{statement}"

relativeToThisFile = (filePath, dirname) ->
  dirname ?= __dirname
  path.join dirname, filePath

module.exports = {log, relativeToThisFile}
