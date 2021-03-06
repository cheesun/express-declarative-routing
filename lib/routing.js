(function() {
  var actions, createBuilder, createMiddleware, deepExtend, ensureArray, prepareRoutes, utils, wrapMethodSpecific,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  utils = require('./utils');

  deepExtend = utils.deepExtend;

  ensureArray = utils.ensureArray;

  actions = ['use', 'all', 'options', 'get', 'post', 'put', 'delete'];

  createBuilder = function(app, action, route, endpoint, groups) {
    if (groups == null) {
      groups = [];
    }
    return function() {
      console.log('| ' + action.toUpperCase() + ' | ' + route + ' | ' + groups.join(', ') + ' |  |');
      if (endpoint) {
        return app[action](route, endpoint);
      }
    };
  };

  wrapMethodSpecific = function(methods, middleware) {
    return function(req, res, next) {
      var _ref;
      if (_ref = req.method.toLowerCase(), __indexOf.call(ensureArray(methods), _ref) >= 0) {
        return middleware(req, res, next);
      } else {
        return next();
      }
    };
  };

  createMiddleware = function(app, name, route, middleware, action) {
    var actionText, m, _i, _len, _ref, _results;
    if (action == null) {
      action = null;
    }
    if (action) {
      actionText = "" + (action.toUpperCase()) + " ";
    } else {
      actionText = '';
    }
    console.log('adding ' + name + ' middleware for ' + actionText + route);
    _ref = ensureArray(middleware);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      m = _ref[_i];
      if (action) {
        _results.push(app.use(route, wrapMethodSpecific(action, m)));
      } else {
        _results.push(app.use(route, m));
      }
    }
    return _results;
  };

  prepareRoutes = function(app, baseRoute, routeObject, groups) {
    var deeperRoute, endpoint, key, newGroups, toDo, value, _i, _len, _ref;
    if (groups == null) {
      groups = [];
    }
    toDo = [];
    if (routeObject) {
      for (key in routeObject) {
        value = routeObject[key];
        if (key !== '_middleware') {
          if (__indexOf.call(actions, key) >= 0) {
            if (routeObject._middleware != null) {
              createMiddleware(app, groups[groups.length - 1], baseRoute, routeObject._middleware, key);
            }
            _ref = ensureArray(value);
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              endpoint = _ref[_i];
              toDo.push(createBuilder(app, key, baseRoute, endpoint, groups));
            }
          } else {
            if (key[0] === '_') {
              deeperRoute = baseRoute;
              newGroups = groups.concat([key.slice(1)]);
            } else {
              key = key.replace('$', ':');
              deeperRoute = baseRoute + '/' + key;
              newGroups = groups;
            }
            if (routeObject._middleware) {
              createMiddleware(app, newGroups[newGroups.length - 1], deeperRoute, routeObject._middleware);
            }
            toDo.push.apply(toDo, prepareRoutes(app, deeperRoute, value, newGroups));
          }
        }
      }
    }
    return toDo;
  };

  exports.buildRoutes = function(app, routes, callback) {
    var baseRoute, prepared, routeObject, routeObjects, toDo, _i, _j, _len, _len1, _results;
    toDo = [];
    for (baseRoute in routes) {
      routeObjects = routes[baseRoute];
      for (_i = 0, _len = routeObjects.length; _i < _len; _i++) {
        routeObject = routeObjects[_i];
        toDo.push.apply(toDo, prepareRoutes(app, baseRoute, routeObject));
      }
    }
    if (callback) {
      return callback(toDo);
    } else {
      console.log('ROUTING TABLE:');
      console.log('| verb | route | groups | params |');
      console.log('| ---- | ----- | ------ | ------ |');
      _results = [];
      for (_j = 0, _len1 = toDo.length; _j < _len1; _j++) {
        prepared = toDo[_j];
        _results.push(prepared());
      }
      return _results;
    }
  };

}).call(this);
