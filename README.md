express-declarative-routing
===========================

declarative routing for express.js

## NPM Package

npm install express-declarative-routing


## we need your help!

A few things on the roadmap:

- full testing
- cover all features of express.js routing


## getting started

1. routes are declared as nested objects, leaf values point to controller methods
- object properties are route element names
- '_middlware' can be used to declare what middleware is available to subroutes definitions
- '_middlewareName1_middlewareName2' can be used to declare that subroutes are using the middleware
- '$' in routes will be replaced with ':', which signifies a wildcard in express routing

2. run build routes
- this builds middleware in front of certain routes as required
- creates a list of functions which will build the routes later
- also conveniently outputs a table of the routes it's built and what middleware applies to each

Example:

### declare routes (for example in /routes/some_routes.coffee)

```CoffeeScript
controller = require(./controller)
module.export =
  route_a:
    subroute_b:
      _middleware: [ middlware 1 ] # middleware shared  by all routes in subroute_b
      get: controller.getAB
      put: controller.putAB
    subroute_c:
      post: controller.getAC
    _groupName:
      _middleware: [ middleware1, middleware2 ] # middleware shared by all routes in groupName
      subroute_d:
        $variable:
          get: controller.getAD
      subroute_e:
        get: controller.getAE
        post: controller.postAE
  route_b:
    all: controller.getB
```

### build routes (usually server.js/coffee, where the express app is available)

```CoffeeScript
routing = require("./lib/routing")
app = express()
routing.buildRoutes(app,
  '/mountRoute' : [
    require("./some_routes")
  ]
)
```

### this results in the following routes:

```
/mountRoute/route_a/subroute_b GET PUT
/mountRoute/route_a/subroute_c GET
/mountRoute/route_a/subroute_c/subroute_d/:variable GET
/mountRoute/route_a/subroute_c/subroute_e/ GET POST
/mountRoute/route_b GET POST PUT DELETE OPTIONS


```
