module.exports =
  deepExtend: (object, extenders...) ->
    return {} if not object?
    for other in extenders
      for own key, val of other
        if not object[key]? or typeof val isnt "object"
          object[key] = val
        else
          object[key] = deepExtend object[key], val
    object

  ensureArray: (thing) ->
    if thing instanceof Array then thing else [thing]

