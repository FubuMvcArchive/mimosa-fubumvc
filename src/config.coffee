"use strict"

_ = require "lodash"
path = require 'path'
fs = require 'fs'

exports.defaults = ->
  fubumvc:
    usePolling: true
    interval: 500
    binaryInterval: 1000
    excludePaths: ["bin", "obj", /^\./]
    conventions: []

exports.validate = (config, validators) ->
  errors = []
  {fubumvc} = config
  unless fubumvc? and _.isObject fubumvc
    errors.push "fubumvc config"
    return errors

  {excludePaths, conventions, usePolling, interval, binaryInterval, baseDir} = fubumvc

  unless !baseDir? or (baseDir? and fs.existsSync baseDir)
    errors.push "fubumvc.baseDir"
    return errors

  unless usePolling? and _.isBoolean usePolling
    errors.push "fubumvc.usePolling"
    return errors

  unless interval? and _.isNumber interval
    errors.push "fubumvc.interval"
    return errors

  unless binaryInterval? and _.isNumber binaryInterval
    errors.push "fubumvc.binaryInterval"
    return errors

  unless excludePaths? and _.isArray excludePaths
    errors.push "fubumvc.excludePaths"
    return errors

  excludePathsOk = _.all excludePaths, (item) ->
    _.isString(item) or _.isRegExp(item)

  unless excludePathsOk
    errors.push "fubumvc.excludePaths entries must be either strings or regexes"
    return errors

  unless conventions? and _.isArray conventions
    errors.push "fubumvc.conventions"
    return errors

  conventionsOk = _.all conventions, (item) ->
    _.isObject(item) and _.all ["match", "transform"], (func) -> _.isFunction item[func]

  unless conventionsOk
    errors.push "fubumvc.conventions entries must be objects with match: (file, ext) -> and transform: (file, path) ->"
    return errors

  #auto-include the sourceDir and compiledDir into excludePaths list
  {watch: {sourceDir, compiledDir}} = config
  ignorePaths = _.map [sourceDir, compiledDir, 'node_modules'], (p) -> path.basename p

  config.fubumvc.excludePaths = excludePaths.concat ignorePaths
  config.fubumvc.sourceDir = sourceDir
  config.fubumvc.compiledDir = compiledDir
  config.fubumvc.isBuild = config.isBuild

  errors
