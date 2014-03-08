utils = require('./utils')
deepExtend = utils.deepExtend
ensureArray = utils.ensureArray

actions = [
  'use'
  'all'
  'options'
  'get'
  'post'
  'put'
  'delete'
]

# preparing the routes actually creates middleware first
# and returns functions which are used to create the routes later
# this allows middleware to be created before routes
# therefore we should only call buildRoutes once

createBuilder = (app, action, route, endpoint, groups=[]) ->
  return () ->
    console.log('| ' + action.toUpperCase() + ' | ' + route + ' | ' + groups.join(', ') + ' |  |')
    app[action](route, endpoint) if endpoint

createMiddleware = (app, name, route, middleware) ->
  console.log('adding ' + name + ' middleware for ' + route)
  for m in ensureArray(middleware)
    app.use(route, m)

prepareRoutes = (app, baseRoute, routeObject, groups=[]) ->
  # collect the routes
  toDo = []
  if routeObject
    for key, value of routeObject when key != '_middleware'
      if key in actions # it's a leaf node of the routes
        createMiddleware(app, groups[groups.length - 1], baseRoute, routeObject._middleware) if routeObject._middleware?
        for endpoint in ensureArray(value)
          toDo.push(createBuilder(app, key, baseRoute, endpoint, groups))
      else
        if key[0] == '_' # it's a group that shares middleware
          deeperRoute = baseRoute
          newGroups = groups.concat([key.slice(1)])
        else # it's a nested route
          key = key.replace('$', ':') # '$' in our routes means ':' in express routes
          deeperRoute = baseRoute + '/' + key
          newGroups = groups

        createMiddleware(app, newGroups[newGroups.length - 1], deeperRoute, routeObject._middleware) if routeObject._middleware
        toDo.push.apply(toDo, prepareRoutes(app, deeperRoute, value, newGroups))

  return toDo

exports.buildRoutes = (app, routes, callback) ->
  toDo = []
  for baseRoute, routeObjects of routes
    for routeObject in routeObjects
      toDo.push.apply(toDo, prepareRoutes(app, baseRoute, routeObject))
  if callback
    callback(toDo)
  else
    console.log('ROUTING TABLE:')
    console.log('| verb | route | groups | params |')
    console.log('| ---- | ----- | ------ | ------ |')
    for prepared in toDo
      prepared()
