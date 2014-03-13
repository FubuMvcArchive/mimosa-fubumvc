"use strict"

exports.defaults = ->
  fubuImport:
    placeholder: ""

exports.placeholder = ->
  """
  \t

    # fubu-import:             # Put some meaningful comments here
  """
exports.validate = (config, validators) ->
  errors = []
  errors
