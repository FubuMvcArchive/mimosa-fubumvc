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
      # {
        # match: (file, ext) -> true #filename and extension, return true/false,
        # transform: (file, path) -> file #is filename, path is path module
        # }
    # ]
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

  #TODO: validation for conventions

  #auto-include the sourceDir and compiledDir into excludePaths list
  {watch: {sourceDir, compiledDir}} = config
  ignorePaths = _.map [sourceDir, compiledDir], (p) -> path.basename p

  config.fubumvc.excludePaths = excludePaths.concat ignorePaths
  config.fubumvc.sourceDir = sourceDir
  config.fubumvc.compiledDir = compiledDir
  config.fubumvc.extensions = config.extensions?.copy || []
  config.fubumvc.isBuild = config.isBuild

  errors
