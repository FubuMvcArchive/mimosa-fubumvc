"use strict"

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
  console.log fubumvc

  errors
