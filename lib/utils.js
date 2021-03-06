(function() {
  var __slice = [].slice,
    __hasProp = {}.hasOwnProperty;

  module.exports = {
    deepExtend: function() {
      var extenders, key, object, other, val, _i, _len;
      object = arguments[0], extenders = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (object == null) {
        return {};
      }
      for (_i = 0, _len = extenders.length; _i < _len; _i++) {
        other = extenders[_i];
        for (key in other) {
          if (!__hasProp.call(other, key)) continue;
          val = other[key];
          if ((object[key] == null) || typeof val !== "object") {
            object[key] = val;
          } else {
            object[key] = deepExtend(object[key], val);
          }
        }
      }
      return object;
    },
    ensureArray: function(thing) {
      if (thing instanceof Array) {
        return thing;
      } else {
        return [thing];
      }
    }
  };

}).call(this);
