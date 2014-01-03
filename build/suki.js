(function() {
  var Suki, _ref,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Suki = window.Suki = {};

  Suki.trigger = function() {
    var arg, _ref;
    arg = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = Suki.Event).triggerAll.apply(_ref, arg);
  };

  Object.defineProperty(Suki, 'stage', {
    get: function() {
      if (!Suki._stage) {
        Suki._stage = new Suki.Stage();
      }
      return Suki._stage;
    }
  });

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

    Base.getter('id', function() {
      if (this._UUID) {
        return this._UUID;
      } else {
        if (!Suki.Base.UUID) {
          Suki.Base.UUID = 1;
        }
        return this._UUID = "SUKI_" + this.constructor.name + "_" + (Suki.Base.UUID++);
      }
    });

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
      if ((_ref1 = Suki.Event._handlers[eventType]) != null) {
        _ref1.filter(function(item) {
          return item.caller === _this;
        }).forEach(function(item) {
          var _ref2;
          return (_ref2 = item.handler).call.apply(_ref2, [item.caller].concat(__slice.call(arg)));
        });
      }
      return this;
    };

    Event.prototype.bind = function(eventType, handler) {
      if (!Suki.Event._handlers[eventType]) {
        Suki.Event._handlers[eventType] = [];
      }
      Suki.Event._handlers[eventType].push({
        caller: this,
        handler: handler
      });
      return this;
    };

    Event.prototype.unbind = function(eventType, handler) {
      var index, item, _eventType, _handlers, _i, _ref1, _ref2;
      _ref1 = Suki.Event._handlers;
      for (_eventType in _ref1) {
        if (!__hasProp.call(_ref1, _eventType)) continue;
        _handlers = _ref1[_eventType];
        if (!(eventType && eventType !== _eventType)) {
          for (index = _i = _ref2 = _handlers.length - 1; _i >= 0; index = _i += -1) {
            item = _handlers[index];
            if (item.caller === this) {
              if (!(handler && handler !== item.handler)) {
                _handlers.splice(index, 1);
              }
            }
          }
          if (!Suki.Event._handlers[_eventType].length) {
            delete Suki.Event._handlers[_eventType];
          }
        }
      }
      return this;
    };

    Event.prototype.one = function(eventType, handler) {
      var wrapperHandler;
      wrapperHandler = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        this.unbind(eventType, wrapperHandler);
        return handler.call.apply(handler, [this].concat(__slice.call(args)));
      };
      this.bind(eventType, wrapperHandler);
      return this;
    };

    Event._handlers = {};

    Event.triggerAll = function() {
      var arg, eventType, receiverCount;
      eventType = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      receiverCount = 0;
      if (Event._handlers[eventType]) {
        Event._handlers[eventType].forEach(function(item) {
          var _ref1;
          receiverCount += 1;
          return (_ref1 = item.handler).call.apply(_ref1, [item.caller].concat(__slice.call(arg)));
        });
      }
      return receiverCount;
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

    Timer.prototype.destroy = function() {
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
      var arg, type, _ref1, _ref2;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.type = type;
      if (!Suki.Entity.definitions[this.type]) {
        throw new Error("Entity '" + this.type + "' must be defined before created.");
      }
      _ref1 = Suki.Entity.definitions[this.type], this._constructor = _ref1._constructor, this._destructor = _ref1._destructor;
      this.style = {};
      this.speed = {
        x: 0,
        y: 0
      };
      this._included = {};
      (_ref2 = this._constructor).call.apply(_ref2, [this].concat(__slice.call(arg)));
      this.layer = Suki.Layer.current;
      Suki.trigger('CreateEntity', this);
      this.bind('BeforeDraw', function() {
        var newSpeed;
        newSpeed = {
          x: this.speed.x,
          y: this.speed.y
        };
        if (this.speed.x || this.speed.y) {
          this.trigger('beforeMove', newSpeed);
        }
        this.x += newSpeed.x;
        return this.y += newSpeed.y;
      });
    }

    Entity.prototype.attr = function(key, value) {
      var obj, _results;
      obj = key;
      if (typeof key === 'string') {
        if (typeof value === 'undefined') {
          return this[key];
        }
        obj = {};
        obj[key] = value;
      }
      _results = [];
      for (key in obj) {
        if (!__hasProp.call(obj, key)) continue;
        value = obj[key];
        _results.push(this[key] = value);
      }
      return _results;
    };

    Entity.prototype.include = function() {
      var arg, type, _constructor, _destructor, _ref1;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (!Suki.Entity.definitions[type]) {
        throw new Error("Entity '" + type + "' must be defined before created.");
      }
      _ref1 = Suki.Entity.definitions[type], _constructor = _ref1._constructor, _destructor = _ref1._destructor;
      _constructor.call.apply(_constructor, [this].concat(__slice.call(arg)));
      this._included[type] = _destructor;
      return this;
    };

    Entity.prototype.is = function(type) {
      return Boolean(this.type === type || this._included[type]);
    };

    Entity.prototype.css = function(key, value) {
      if (value === void 0) {
        return this.style[key];
      } else {
        if (this.style[key] !== value) {
          this.style[key] = value;
          return this.dirty = true;
        }
      }
    };

    Entity.prototype.destroy = function() {
      var arg, destructor, key, _ref1;
      arg = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      delete this.scene;
      _ref1 = this._included;
      for (key in _ref1) {
        if (!__hasProp.call(_ref1, key)) continue;
        destructor = _ref1[key];
        destructor.call.apply(destructor, [this].concat(__slice.call(arg)));
      }
      Suki.trigger('DestroyEntity', this);
      this.unbind();
      return typeof this._destructor === "function" ? this._destructor.apply(this, arg) : void 0;
    };

    Entity.definitions = {};

    Entity.define = function(type, constructor, destructor) {
      this.definitions[type] = {
        _constructor: constructor || function() {},
        _destructor: destructor || function() {}
      };
      return this;
    };

    Entity.create = function() {
      var arg, type;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(this, [type].concat(__slice.call(arg)), function(){});
    };

    dirtyProperty = ['width', 'height', 'x', 'y'];

    dirtyProperty.forEach(function(property) {
      Entity.getter(property, function() {
        return this["_" + property];
      });
      return Entity.setter(property, function(value) {
        value = Math.round(value);
        if (this[property] !== value) {
          this.dirty = true;
          return this["_" + property] = value;
        }
      });
    });

    return Entity;

  }).call(this, Suki.Base);

  Suki.Layer = (function(_super) {
    __extends(Layer, _super);

    Layer.include(Suki.Timer);

    Layer.include(Suki.Event);

    function Layer() {
      var arg, type, _ref1;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.type = type;
      if (!Suki.Layer.definitions[this.type]) {
        throw new Error("Layer '" + this.type + "' must be defined before created.");
      }
      _ref1 = Suki.Layer.definitions[this.type], this._constructor = _ref1._constructor, this._destructor = _ref1._destructor;
      this.bind('CreateEntity', function(entity) {
        if (Suki.Layer.current === this) {
          return this.entities.push(entity);
        }
      });
      this.bind('DestroyEntity', function(entity) {
        var index;
        index = this.entities.indexOf(entity);
        if (index !== -1) {
          return this.entities.splice(index, 1);
        }
      });
      Suki.Layer.current = this;
      this.entities = [];
      this._constructor.apply(this, arg);
      this.scene = Suki.Scene.current;
      Suki.trigger('CreateLayer', this);
    }

    Layer.prototype.destroy = function() {
      var arg, entity, _i, _len, _ref1;
      arg = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      delete this.scene;
      _ref1 = this.entities;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        entity = _ref1[_i];
        entity.destroy();
      }
      this.entities = [];
      Suki.trigger('DestroyLayer', this);
      this.unbind();
      return typeof this._destructor === "function" ? this._destructor.apply(this, arg) : void 0;
    };

    Layer.definitions = {};

    Layer.define = function(type, constructor, destructor) {
      this.definitions[type] = {
        _constructor: constructor || function() {},
        _destructor: destructor
      };
      return this;
    };

    Layer.create = function() {
      var arg, type;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(this, [type].concat(__slice.call(arg)), function(){});
    };

    Object.defineProperty(Layer, 'current', {
      get: function() {
        if (!this._current) {
          this.create(this._defaultLayerType);
        }
        return this._current;
      },
      set: function(layer) {
        return this._current = layer;
      }
    });

    Layer.clear = function() {
      return this.definitions = {};
    };

    Layer._defaultLayerType = 'SUKI_DEFAULT_LAYER';

    Layer.define(Layer._defaultLayerType);

    return Layer;

  })(Suki.Base);

  Suki.Scene = (function(_super) {
    __extends(Scene, _super);

    Scene.include(Suki.Timer);

    Scene.include(Suki.Event);

    function Scene() {
      var arg, type, _ref1,
        _this = this;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.type = type;
      if (!Suki.Scene.definitions[this.type]) {
        throw new Error("Scene '" + this.type + "' must be defined before created.");
      }
      _ref1 = Suki.Scene.definitions[this.type], this._constructor = _ref1._constructor, this._destructor = _ref1._destructor;
      this.bind('CreateLayer', function(layer) {
        if (Suki.Scene.current === this) {
          return this.layers.push(layer);
        }
      });
      this.bind('DestroyLayer', function(layer) {
        var index;
        index = this.layers.indexOf(layer);
        if (index !== -1) {
          return this.layers.splice(index, 1);
        }
      });
      this.layers = [];
      Suki.Scene.current = this;
      this._constructor.apply(this, arg);
      Suki.trigger('CreateScene', this);
      this.frameTimer = new Suki.Timer(function() {
        return _this.enterFrame();
      }, 16, Infinity);
    }

    Scene.prototype.destroy = function() {
      var arg, layer, _i, _len, _ref1;
      arg = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.frameTimer.destroy();
      _ref1 = this.layers;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        layer = _ref1[_i];
        layer.destroy();
      }
      this.layers = [];
      Suki.trigger('DestroyScene', this);
      this.unbind();
      return typeof this._destructor === "function" ? this._destructor.apply(this, arg) : void 0;
    };

    Scene.prototype.enterFrame = function() {
      var layer, _i, _len, _ref1;
      Suki.trigger('EnterFrame');
      Suki.trigger('BeforeDraw');
      _ref1 = this.layers;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        layer = _ref1[_i];
        Suki.trigger('DrawLayer', layer);
      }
      Suki.trigger('DrawCamera');
      return Suki.trigger('AfterDraw');
    };

    Scene.definitions = {};

    Scene.define = function(type, constructor, destructor) {
      this.definitions[type] = {
        _constructor: constructor || function() {},
        _destructor: destructor || function() {}
      };
      return this;
    };

    Scene.create = function() {
      var arg, type;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(this, [type].concat(__slice.call(arg)), function(){});
    };

    Object.defineProperty(Scene, 'current', {
      get: function() {
        if (!this._current) {
          this.create(this._defaultSceneType);
        }
        return this._current;
      },
      set: function(newScene) {
        if (this._current) {
          this._current.destroy();
        }
        return this._current = newScene;
      }
    });

    Scene.clear = function() {
      return this.definitions = {};
    };

    Scene._defaultSceneType = 'SUKI_DEFAULT_SCENE';

    Scene.define(Scene._defaultSceneType);

    return Scene;

  })(Suki.Base);

  Suki.Stage = (function(_super) {
    __extends(Stage, _super);

    Stage.include(Suki.Event);

    function Stage(width, height, camera) {
      var ELEMENT_TYPE, pCanvas, property, _i, _j, _k, _len, _len1, _len2, _ref1, _ref2, _ref3;
      if (width == null) {
        width = 926.4;
      }
      if (height == null) {
        height = 246.4;
      }
      if (typeof camera === 'string') {
        camera = document.getElementById(element);
        if (!camera) {
          throw new Error("Could't find the element by id " + camera);
        }
      }
      if (camera) {
        ELEMENT_TYPE = HTMLElement || Element;
        if (!(camera instanceof ELEMENT_TYPE)) {
          throw new TypeError('`camera` must be a string or an HTMLElement');
        }
      } else {
        camera = document.createElement('div');
        camera.id = this.id;
        document.body.appendChild(camera);
      }
      pCanvas = this.camera = {
        dom: camera,
        scale: {},
        scroll: {}
      };
      _ref1 = ['x', 'y'];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        property = _ref1[_i];
        Object.defineProperty(this.camera.scale, property, {
          get: function() {
            return this["_" + property];
          },
          set: function(value) {
            var layer, _j, _len1, _ref2;
            pCanvas.dirty = true;
            _ref2 = Suki.Scene.current.layers;
            for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
              layer = _ref2[_j];
              layer.deepDirty = true;
            }
            return this["_" + property] = value;
          }
        });
      }
      _ref2 = ['x', 'y'];
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        property = _ref2[_j];
        Object.defineProperty(this.camera.scroll, property, {
          get: function() {
            return this["_" + property];
          },
          set: function(value) {
            var layer, _k, _len2, _ref3;
            pCanvas.dirty = true;
            _ref3 = Suki.Scene.current.layers;
            for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
              layer = _ref3[_k];
              layer.dirty = true;
            }
            return this["_" + property] = value;
          }
        });
      }
      _ref3 = ['width', 'height'];
      for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
        property = _ref3[_k];
        Object.defineProperty(this.camera, property, {
          get: function() {
            return this["_" + property];
          },
          set: function(value) {
            this.dirty = true;
            return this["_" + property] = value;
          }
        });
      }
      this.camera.scale.x = 1;
      this.camera.scale.y = 1;
      this.camera.scroll.x = 0;
      this.camera.scroll.y = 0;
      this.camera.width = width;
      this.camera.height = height;
      this.bind('DrawCamera', function() {
        if (this.camera.dirty) {
          this.camera.dom.style.width = "" + (this.camera.width * this.camera.scale.x) + "px";
          this.camera.dom.style.height = "" + (this.camera.height * this.camera.scale.y) + "px";
          return this.camera.dirty = false;
        }
      });
      this.bind('DrawLayer', function(layer) {
        var element, entity, key, layerElement, scroll, value, _l, _len3, _ref4, _ref5;
        if (layer.dirty) {
          layerElement = document.getElementById(layer.id);
          scroll = {
            x: this.camera.scroll.x,
            y: this.camera.scroll.y
          };
          layer.trigger('scroll', scroll);
          layerElement.style.left = -("" + scroll.x + "px");
          layerElement.style.top = -("" + scroll.y + "px");
          layer.dirty = false;
        }
        _ref4 = layer.entities;
        for (_l = 0, _len3 = _ref4.length; _l < _len3; _l++) {
          entity = _ref4[_l];
          if (layer.deepDirty || entity.dirty) {
            element = document.getElementById(entity.id);
            element.style.left = "" + (entity.x * this.camera.scale.x) + "px";
            element.style.top = "" + (entity.y * this.camera.scale.y) + "px";
            element.style.width = "" + (entity.width * this.camera.scale.x) + "px";
            element.style.height = "" + (entity.height * this.camera.scale.y) + "px";
            _ref5 = entity.style;
            for (key in _ref5) {
              if (!__hasProp.call(_ref5, key)) continue;
              value = _ref5[key];
              element.style[key] = value;
            }
            entity.dirty = false;
          }
        }
        return layer.deepDirty = false;
      });
      this.bind('CreateEntity', function(entity) {
        var element, layerElement;
        element = document.createElement('div');
        element.id = entity.id;
        element.style.position = 'absolute';
        layerElement = document.getElementById(entity.layer.id);
        return layerElement.appendChild(element);
      });
      this.bind('CreateLayer', function(layer) {
        var layerElement;
        layerElement = document.createElement('div');
        layerElement.id = layer.id;
        layerElement.style.position = 'absolute';
        layerElement.style.left = '0';
        layerElement.style.top = '0';
        layerElement.style.width = '100%';
        layerElement.style.height = '100%';
        layerElement.style.overflow = 'hidden';
        return this.camera.dom.appendChild(layerElement);
      });
    }

    Stage.prototype.clear = function() {
      return this.camera.innerHTML = '';
    };

    Stage.prototype.removeEntity = function(entity) {
      var element;
      element = document.getElementById(entity.id);
      if (element) {
        return this.camera.dom.removeClild(element);
      }
    };

    Stage.prototype.removeLayer = function(layer) {
      var layerElement;
      layerElement = document.getElementById(layer.id);
      return this.camera.dom.removeClild(layerElement);
    };

    return Stage;

  })(Suki.Base);

  Suki.Vector = (function(_super) {
    __extends(Vector, _super);

    function Vector() {
      var arg, type;
      type = arguments[0], arg = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.type = type;
      if (this.type === Suki.Vector.CIRCLE) {
        this.center = [arg[0][0], arg[0][1]];
        this.radius = arg[1];
      } else if (this.type === Suki.Vector.POLYGON) {
        this.points = arg;
      } else {
        throw new Error('`type` must be either `Suki.Vector.CIRCLE` or `Suki.Vector.POLYGON`');
      }
    }

    Vector.prototype.collided = function(other) {
      var distance, test, totalRadius, x, y;
      if (this.type === Suki.Vector.CIRCLE && other.type === Suki.Vector.CIRCLE) {
        totalRadius = this.radius + other.radius;
        x = this.center[0] - other.center[0];
        y = this.center[1] - other.center[1];
        distance = Math.sqrt(x * x + y * y);
        return distance < totalRadius;
      } else if (this.type === Suki.Vector.POLYGON && other.type === Suki.Vector.POLYGON) {
        test = function(polygonA, polygonB) {
          var currentPoint, dot, index, interval, length, maxA, maxB, minA, minB, nextPoint, normal, point, _i, _j, _k, _len, _len1, _len2, _ref1, _ref2, _ref3;
          _ref1 = polygonA.points;
          for (index = _i = 0, _len = _ref1.length; _i < _len; index = ++_i) {
            currentPoint = _ref1[index];
            nextPoint = polygonA.points[index === polygonA.points.length - 1 ? 0 : index + 1];
            normal = [currentPoint[1] - nextPoint[1], nextPoint[0] - currentPoint[0]];
            length = Math.sqrt(normal[0] * normal[0] + normal[1] * normal[1]);
            normal[0] /= length;
            normal[1] /= length;
            minA = minB = Infinity;
            maxA = maxB = -Infinity;
            _ref2 = polygonA.points;
            for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
              point = _ref2[_j];
              dot = point[0] * normal[0] + point[1] * normal[1];
              if (dot > maxA) {
                maxA = dot;
              }
              if (dot < minA) {
                minA = dot;
              }
            }
            _ref3 = polygonB.points;
            for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
              point = _ref3[_k];
              dot = point[0] * normal[0] + point[1] * normal[1];
              if (dot > maxB) {
                maxB = dot;
              }
              if (dot < minB) {
                minB = dot;
              }
            }
            if (minA < minB) {
              interval = minB - maxA;
            } else {
              interval = minA - maxB;
            }
            if (!(interval < 0)) {
              return true;
            }
          }
        };
        return !test(this, other) && !test(other, this);
      }
    };

    Vector.CIRCLE = 'c';

    Vector.POLYGON = 'p';

    Vector.prototype.duplicate = function() {
      if (this.type === Suki.Vector.CIRCLE) {
        return new Suki.Vector(this.type, this.center, this.radius);
      } else {
        return (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args);
          return Object(result) === result ? result : child;
        })(Suki.Vector, [this.type].concat(__slice.call(this.points)), function(){});
      }
    };

    Vector.prototype.relative = function(x, y) {
      var index, newVector, point, _i, _len, _ref1;
      newVector = this.duplicate();
      if (this.type === Suki.Vector.CIRCLE) {
        newVector.center = [newVector.center[0] + x, newVector.center[1] + y];
      } else {
        _ref1 = newVector.points;
        for (index = _i = 0, _len = _ref1.length; _i < _len; index = ++_i) {
          point = _ref1[index];
          newVector.points[index] = [point[0] + x, point[1] + y];
        }
      }
      return newVector;
    };

    Vector.prototype.rotate = function(deg, origin) {
      var index, newVector, point, _i, _len, _ref1;
      newVector = this.duplicate();
      if (this.type === Suki.Vector.CIRCLE) {
        newVector.center = Suki.Vector.rotatePoint(newVector.center, deg, origin);
      } else {
        _ref1 = newVector.points;
        for (index = _i = 0, _len = _ref1.length; _i < _len; index = ++_i) {
          point = _ref1[index];
          newVector.points[index] = Suki.Vector.rotatePoint(point, deg, origin);
        }
      }
      return newVector;
    };

    Vector.rotatePoint = function(source, deg, origin) {
      return [Math.round(source[0] * Math.cos(deg * Math.PI / 180) - source[1] * Math.sin(deg * Math.PI / 180)), Math.round(source[0] * Math.sin(deg * Math.PI / 180) + source[1] * Math.cos(deg * Math.PI / 180))];
    };

    return Vector;

  })(Suki.Base);

  Suki.Entity.define('Circle', function() {
    return this.css('borderRadius', '99999px');
  });

  Suki.Entity.define('Collision', function() {
    this.collision = function(boundary, collisionMap) {
      this.collision.boundary = boundary;
      return this.collision.collisionMap = collisionMap;
    };
    return this.bind('beforeMove', function(speed) {
      var entities, keys, origin, originSpeed, sc,
        _this = this;
      origin = {
        top: this.y,
        left: this.x
      };
      originSpeed = {
        x: speed.x,
        y: speed.y
      };
      this.x += speed.x;
      this.y += speed.y;
      entities = this.layer.entities.filter(function(entity) {
        return entity.is('Collision') && entity !== _this;
      });
      if (typeof this.collision.collisionMap === 'object') {
        keys = Object.keys(_collisionMap);
        entities = entities.filter(function(entity) {
          return keys.some(function(key) {
            return entity.is(key);
          });
        });
      }
      sc = {};
      if (Math.abs(speed.x) > Math.abs(speed.y)) {
        sc.x = speed.x / (speed.y ? Math.abs(speed.y) : Math.abs(speed.x));
        sc.y = speed.y ? speed.y / Math.abs(speed.y) : 0;
      } else {
        sc.x = speed.x ? speed.x / Math.abs(speed.x) : 0;
        sc.y = speed.y / (speed.x ? Math.abs(speed.x) : Math.abs(speed.y));
      }
      return entities.some(function(entity) {
        var colliede, step;
        step = 0;
        colliede = false;
        while (entity.collision.boundary.relative(entity.x, entity.y).collided(_this.collision.boundary.relative(_this.x, _this.y))) {
          console.log(entity.id, speed);
          console.log(entity.id, 'sc', sc);
          if (speed.x === 0 && speed.y === 0) {
            break;
          }
          colliede = true;
          step += 1;
          speed.x = Math.round(originSpeed.x - step * sc.x);
          speed.y = Math.round(originSpeed.y - step * sc.y);
          _this.y = origin.top + speed.y;
          _this.x = origin.left + speed.x;
        }
        if (colliede) {
          speed.x = originSpeed.x;
          speed.y = originSpeed.y;
          _this.x = origin.left;
          _this.y = origin.top;
          _this.trigger('hit', entity, {
            currentSpeed: speed,
            x: step * sc.x,
            y: step * sc.y
          });
          return true;
        }
      });
    });
  });

  Suki.Entity.define('Color', function(backgroundColor) {
    this.color = function(backgroundColor) {
      return this.css('backgroundColor', backgroundColor);
    };
    if (backgroundColor) {
      return this.color(backgroundColor);
    }
  });

  Suki.Entity.define('Pixel', function(imageURL) {
    var canvas, context;
    this.include('Image');
    this.img = imageURL;
    img.src = imageURL;
    canvas = document.createElement('canvas');
    context = canvas.getContext('2d');
    context.drawImage(img, 0, 0);
    return context.getImageData(x, y, 1, 1).data;
  });

  Suki.Entity.define('Rotate', function(imageURL) {
    var canvas, context;
    this.include('Image');
    this.img = imageURL;
    img.src = imageURL;
    canvas = document.createElement('canvas');
    context = canvas.getContext('2d');
    context.drawImage(img, 0, 0);
    return context.getImageData(x, y, 1, 1).data;
  });

  Suki.Entity.define('Sprite', function(imgURL, imgWidth, imgHeight, spriteX, spriteY, spriteWidth, spriteHeight) {
    this.width = spriteWidth;
    this.height = spriteHeight;
    this.css('backgroundImage', "url(" + imgURL + ")");
    return this.css('backgroundPosition', "-" + spriteX + "px -" + spriteY + "px");
  });

}).call(this);
