routing = require("../src/routing")
express = require("express")
app = express()

controller =
  testGet: (req, res) ->
    response.setHeader("Content-Type", "application/json")
    response.end(JSON.stringify('success!'))

routes =
  test:
    get: controller.testGet

routing.buildRoutes(app,
  '' : [routes])
