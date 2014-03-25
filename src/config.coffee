"use strict"

_ = require "lodash"
path = require 'path'

exports.defaults = ->
  fubumvc:
    excludePaths: ["bin", "obj", /^\./]

exports.placeholder = ->
  """
  \t

  # fubumvc:
    # excludePaths: ["bin", "obj", /^\./]
  """

exports.validate = (config, validators) ->
  errors = []
  {fubumvc} = config
  unless fubumvc? and _.isObject fubumvc
    errors.push "fubumvc config"
    return errors

  {excludePaths} = fubumvc
  unless excludePaths? and _.isArray excludePaths
    errors.push "fubumvc.excludePaths"
    return errors

  allItemsOk = _.all excludePaths, (item) ->
    _.isString(item) or _.isRegExp(item)

  unless allItemsOk
    errors.push "fubumvc.excludePaths entries must be either strings or regexes"
    return errors

  #auto-include the sourceDir and compiledDir into excludePaths list
  {watch: {sourceDir, compiledDir}} = config
  assetIgnorePaths = _.map [sourceDir, compiledDir], (p) -> path.basename p

  config.fubumvc.excludePaths = excludePaths.concat assetIgnorePaths

  errors
