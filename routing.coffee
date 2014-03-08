# a declarative routing system
#
# 1. routes are declared as nested objects, leaf values point to controller methods
# - object properties are route element names
# - '_middlware' can be used to declare what middleware is available to subroutes definitions
# - '_middlewareName1_middlewareName2' can be used to declare that subroutes are using the middleware
# - '$' in routes will be replaced with ':', which signifies a wildcard in express routing
#
# 2. run build routes
# - this builds middleware in front of certain routes as required
# - creates a list of functions which will build the routes later
#
# Example:
#
# # require the controller
# controller = require(./controller)
#
# # declare routes
# routes =
#   route_a:
#     subroute_b:
#       _middleware: [ middlware 1 ] # middleware shared  by all routes in subroute_b
#       get: controller.getAB
#       put: controller.putAB
#     subroute_c:
#       post: controller.getAC
#     _groupName:
#       _middleware: [ middleware1, middleware2 ] # middleware shared by all routes in groupName
#       subroute_d:
#         get: controller.getAD
#       subroute_e:
#         get: controller.getAE
#         post: controller.postAE
#   route_b:
#     all: controller.getB
#
# # build routes
# buildRoutes(app, routes)

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
