"use strict"
logger = require 'logmimosa'
path = require 'path'
_ = require 'lodash'

log = (level, statement) ->
  logger[level] "fubumvc: #{statement}"

relativeToThisFile = (filePath, dirname) ->
  dirname ?= __dirname
  path.join dirname, filePath

printObj = (obj, prefix) ->
  withPrefix = (x) -> if prefix? then "#{prefix}.#{x}" else x
  _.each obj, (v,k) ->
    if (_.isObject v)
      printObj(v, withPrefix k)
    else
      console.log "#{withPrefix k}: #{v}"

module.exports = {log, relativeToThisFile, printObj}
