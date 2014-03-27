"use strict"

_ = require "lodash"
path = require 'path'

exports.defaults = ->
  fubumvc:
    excludePaths: ["bin", "obj", /^\./]
    conventions: []

exports.placeholder = ->
  """
  \t

  # fubumvc:
    # excludePaths: ["bin", "obj", /^\./]
    # conventions: [
      # provide 0 or more conventions
      # { 
        # match: (file, ext) ->
          # true #filename and extension, return true/false,
        # transform: (file, path) ->
          # file #filename and path module to do path.join, etc
      # }
    # ]
  """

exports.validate = (config, validators) ->
  errors = []
  {fubumvc} = config
  unless fubumvc? and _.isObject fubumvc
    errors.push "fubumvc config"
    return errors

  {excludePaths, conventions} = fubumvc

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
