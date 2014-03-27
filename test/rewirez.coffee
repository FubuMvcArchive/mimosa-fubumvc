"use strict"

rewire = require 'rewire'
_ = require 'lodash'

rewirez = (path) ->
  result = rewire path
  result.__tempSet__ = (args...) ->
    varName = args[0]
    varValue = args[1]

    if _.isObject(varName) and args.length is 1
      snapShot = _(varName)
        .map (v,k) -> [k, result.__get__ k]
        .reduce((acc, [key, value]) ->
          acc[key] = value
          acc
        , {})
    else if _.isString(varName) and args.length is 2
      snapShot = {}
      snapShot[varName] = varValue

    result.__set__.apply(result, args)
    return () -> result.__set__ snapShot

  result

module.exports = rewirez
