(function() {
  var Suki, preSuki, _ref,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  preSuki = window.Suki;

  Suki = window.Suki = {};

  Suki.noConflict = function() {
    window.Suki = preSuki;
    return this;
  };

  Suki.trigger = function() {
    var arg, _ref;
    arg = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = Suki.Event).triggerAll.apply(_ref, arg);
  };

  Suki.Base = (function() {
    function Base() {}

    Base.include = function(obj) {
      var key, value, _ref, _ref1;
      _ref = obj.prototype;
      for (key in _ref) {
        if (!__hasProp.call(_ref, key)) continue;
        value = _ref[key];
        if (key !== 'constructor') {
          this.prototype[key] = value;
        }
      }
      return (_ref1 = obj.included) != null ? _ref1.apply(this) : void 0;
    };

    Base.getter = function(prop, get) {
      return Object.defineProperty(this.prototype, prop, {
        get: get,
        configurable: true
      });
    };

    Base.setter = function(prop, set) {
      return Object.defineProperty(this.prototype, prop, {
        set: set,
        configurable: true
      });
    };

    Base.prototype.UUID = function() {
      if (!Suki.Base.UUID) {
        Suki.Base.UUID = 1;
      }
      return "SUKI_" + (Suki.Base.UUID++);
    };

    return Base;

  })();

  Suki.Event = (function(_super) {
    __extends(Event, _super);

    function Event() {
      _ref = Event.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Event.prototype.trigger = function() {
      var arg, eventType, _ref1,
        _this = this;
      eventType = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref1 = Suki.Event._handlers[eventType]) != null ? _ref1.filter(function(item) {
        return item.caller === _this;
      }).forEach(function(item) {
        var _ref2;
        return (_ref2 = item.handler).call.apply(_ref2, [item.caller].concat(__slice.call(arg)));
      }) : void 0;
    };

    Event.prototype.bind = function(eventType, handler) {
      if (!Suki.Event._handlers[eventType]) {
        Suki.Event._handlers[eventType] = [];
      }
      return Suki.Event._handlers[eventType].push({
        caller: this,
        handler: handler
      });
    };

    Event.prototype.unbind = function(eventType, handler) {
      return Suki.Event._handlers = Suki._handlers.filter(function(item) {
        return item.caller !== this;
      });
    };

    Event.prototype.once = function(eventType, handler) {
      var wrapperHandler;
      wrapperHandler = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        this.unbind(eventType, wrapperHandler);
        return handler.call.apply(handler, [this].concat(__slice.call(args)));
      };
      return this.bind(eventType, wrapperHandler);
    };

    Event._handlers = [];

    Event.triggerAll = function() {
      var arg, eventType, _ref1;
      eventType = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref1 = Event._handlers[eventType]) != null ? _ref1.forEach(function(item) {
        var _ref2;
        return (_ref2 = item.handler).call.apply(_ref2, [item.caller].concat(__slice.call(arg)));
      }) : void 0;
    };

    return Event;

  }).call(this, Suki.Base);

  Suki.Timer = (function(_super) {
    __extends(Timer, _super);

    Timer.include(Suki.Event);

    function Timer(step, interval, repeat, useRequestAnimationFrame) {
      var beginTick,
        _this = this;
      if (useRequestAnimationFrame == null) {
        useRequestAnimationFrame = true;
      }
      this.meta = {
        beginTime: Date.now(),
        count: 0,
        repeat: repeat
      };
      beginTick = function() {
        var tick;
        if (useRequestAnimationFrame && Suki.Timer.requestAnimationFrame) {
          tick = function() {
            var passedCount, passedTime, timeSlot;
            passedTime = _this.meta.count * interval;
            timeSlot = Date.now() - passedTime - _this.meta.beginTime;
            passedCount = Math.floor(timeSlot / interval);
            while (passedCount && _this.meta.repeat) {
              step();
              ++_this.meta.count;
              --_this.meta.repeat;
              --passedCount;
            }
            if (_this.meta.repeat) {
              return Suki.Timer.requestAnimationFrame.call(window, tick);
            }
          };
          return tick();
        } else {
          return _this.timer = setInterval(function() {
            if (_this.meta.repeat && !_this.paused) {
              step();
              return --_this.meta.repeat;
            } else {
              return clearInterval(_this.timer);
            }
          });
        }
      };
      this.bind('Pause', function() {
        return this.paused = true;
      });
      this.bind('Unpause', function() {
        return this.paused = true;
      });
      beginTick();
    }

    Timer.prototype.delay = function(step, interval) {
      return new Suki.Timer(step, interval, 1);
    };

    Timer.prototype.destructor = function() {
      this.unbind('Unpause');
      this.unbind('Pause');
      return this.paused = true;
    };

    Timer.requestAnimationFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame;

    return Timer;

  })(Suki.Base);

  Suki.Entity = (function(_super) {
    var dirtyProperty,
      _this = this;

    __extends(Entity, _super);

    Entity.include(Suki.Timer);

    function Entity() {
      var arg, constructor, type;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      constructor = Suki.Entity.definitions[type];
      if (!constructor) {
        throw new Error("Component '" + type + "' must be defined before create.");
      }
      this.id = this.UUID();
      this.style = {};
      constructor.call.apply(constructor, [this].concat(__slice.call(arg)));
      Suki.trigger('NewEntity', this);
    }

    Entity.prototype.attr = function(key, value) {
      var obj, _results;
      obj = key;
      if (typeof key === 'string') {
        obj = {};
        obj[key] = value;
      }
      _results = [];
      for (key in obj) {
        if (!__hasProp.call(obj, key)) continue;
        value = obj[key];
        _results.push(this[attr] = value);
      }
      return _results;
    };

    Entity.prototype.include = function() {
      var arg, constructor, type;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      constructor = Suki.Entity.definitions[type];
      if (!constructor) {
        throw new Error("Component '" + type + "' must be defined before create.");
      }
      return constructor.call.apply(constructor, [this].concat(__slice.call(arg)));
    };

    Entity.prototype.css = function(key, value) {
      if (value === void 0) {
        return this.style[key];
      } else {
        this.style[key] = value;
        return this._dirty = true;
      }
    };

    Entity.definitions = {};

    Entity.define = function(type, constructor) {
      return this.definitions[type] = constructor;
    };

    dirtyProperty = ['width', 'height', 'x', 'y'];

    dirtyProperty.forEach(function(property) {
      Entity.getter(property, function() {
        return this["_" + property];
      });
      return Entity.setter(property, function(value) {
        value = Math.round(value);
        if (this[property] !== value) {
          this._dirty = true;
        }
        return this["_" + property] = value;
      });
    });

    return Entity;

  }).call(this, Suki.Base);

  Suki.Scene = (function(_super) {
    __extends(Scene, _super);

    Scene.include(Suki.Timer);

    Scene.include(Suki.Event);

    function Scene() {
      var arg, type, _ref1;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref1 = Suki.Scene.definitions[type], this._constructor = _ref1._constructor, this._destructor = _ref1._destructor;
      if (!constructor) {
        throw new Error("Scene '" + type + "' must be defined before create.");
      }
      this._entities = [];
      this.bind('NewEntity', function(entity) {
        console.log(entity);
        if (Suki.Scene.current === this) {
          return this._entities.push(entity);
        }
      });
    }

    Scene.prototype.start = function() {
      var arg,
        _this = this;
      arg = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return setTimeout(function() {
        Suki.Scene.current = _this;
        _this._constructor.apply(_this, arg);
        _this.frameTimer = new Suki.Timer(function() {
          return _this.enterFrame();
        }, 20, Infinity);
        return _this.bind('AfterDraw', function() {
          return this._entities.forEach(function(entity) {
            return entity._dirty = false;
          });
        });
      }, 0);
    };

    Scene.prototype.enterFrame = function() {
      Suki.trigger('EnterFrame');
      return Suki.trigger('BeforeDraw', this._entities);
    };

    Scene.definitions = {};

    Scene.define = function(type, constructor, destructor) {
      return this.definitions[type] = {
        _constructor: constructor,
        _destructor: destructor
      };
    };

    Object.defineProperty(Scene, 'current', {
      get: function() {
        if (!this._current) {
          throw new Error("Entities must be created inside a scene.");
        }
        return this._current;
      },
      set: function(newScene) {
        Suki.trigger('BeforeSceneChange', this._current, newScene);
        if (this._current) {
          this._current.trigger('beforeSceneDestory');
          this._current.destory();
        }
        return this._current = newScene;
      }
    });

    return Scene;

  })(Suki.Base);

  Suki.Stage = (function(_super) {
    __extends(Stage, _super);

    Stage.include(Suki.Event);

    function Stage(width, height, canvas) {
      var ELEMENT_TYPE, pCanvas,
        _this = this;
      if (width == null) {
        width = 926.4;
      }
      if (height == null) {
        height = 246.4;
      }
      if (typeof canvas === 'string') {
        canvas = document.getElementById(element);
        if (!canvas) {
          throw new Error("Could't find the element by id " + canvas);
        }
      }
      if (canvas) {
        ELEMENT_TYPE = HTMLElement || Element;
        if (!(canvas instanceof ELEMENT_TYPE)) {
          throw new TypeError('`canvas` must be a string or an HTMLElement');
        }
      } else {
        canvas = document.createElement('div');
        canvas.id = this.UUID();
        document.body.appendChild(canvas);
      }
      pCanvas = this.canvas = {
        dom: canvas,
        scale: {},
        scroll: {}
      };
      ['x', 'y'].forEach(function(property) {
        return Object.defineProperty(_this.canvas.scale, property, {
          get: function() {
            return this["_" + property];
          },
          set: function(value) {
            pCanvas._dirty = pCanvas._deepDirty = true;
            return this["_" + property] = value;
          }
        });
      });
      ['x', 'y'].forEach(function(property) {
        return Object.defineProperty(_this.canvas.scroll, property, {
          get: function() {
            return this["_" + property];
          },
          set: function(value) {
            pCanvas._dirty = true;
            return this["_" + property] = value;
          }
        });
      });
      ['width', 'height'].forEach(function(property) {
        return Object.defineProperty(_this.canvas, property, {
          get: function() {
            return this["_" + property];
          },
          set: function(value) {
            this._dirty = true;
            return this["_" + property] = value;
          }
        });
      });
      this.canvas.scale.x = 1;
      this.canvas.scale.y = 1;
      this.canvas.scroll.x = 0;
      this.canvas.scroll.y = 0;
      this.canvas.width = width;
      this.canvas.height = height;
      this.bind('BeforeDraw', function(entities) {
        var _this = this;
        if (this.canvas._dirty) {
          this.canvas.dom.style.left += "" + this.canvas.scroll.x + "px";
          this.canvas.dom.style.top += "" + this.canvas.scroll.y + "px";
          this.canvas.dom.style.width = "" + (this.canvas.width * this.canvas.scale.x) + "px";
          this.canvas.dom.style.height = "" + (this.canvas.height * this.canvas.scale.y) + "px";
          this.canvas._dirty = false;
        }
        entities.forEach(function(entity) {
          var element, key, value, _ref1, _results;
          if (!(_this.canvas._deepDirty || entity._dirty)) {
            return;
          }
          element = document.getElementById(entity.id);
          if (!element) {
            element = document.createElement('div');
            element.id = entity.id;
            element.style.position = 'absolute';
            _this.canvas.dom.appendChild(element);
          }
          element.style.left = "" + (entity.x * _this.canvas.scale.x) + "px";
          element.style.top = "" + (entity.y * _this.canvas.scale.y) + "px";
          element.style.width = "" + (entity.width * _this.canvas.scale.x) + "px";
          element.style.height = "" + (entity.height * _this.canvas.scale.y) + "px";
          _ref1 = entity.style;
          _results = [];
          for (key in _ref1) {
            if (!__hasProp.call(_ref1, key)) continue;
            value = _ref1[key];
            _results.push(element.style[key] = value);
          }
          return _results;
        });
        this.canvas._deepDirty = false;
        return Suki.trigger('AfterDraw', entities);
      });
    }

    return Stage;

  })(Suki.Base);

  Suki.util = {
    extend: function(object, properties) {
      var key, val;
      for (key in properties) {
        val = properties[key];
        object[key] = val;
      }
      return object;
    }
  };

}).call(this);

/*
//# sourceMappingURL=../build/suki.js.map
*/