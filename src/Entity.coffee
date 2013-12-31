class Suki.Entity extends Suki.Base
  @include Suki.Timer

  constructor: (@type, arg...) ->
    unless Suki.Entity.definitions[@type]
      throw new Error "Entity '#{@type}' must be defined before created."

    {@_constructor, @_destructor} = Suki.Entity.definitions[@type]

    @_constructor.call @, arg...
    Suki.trigger 'CreateEntity', @

  style: {}
  _included: {}
  attr: (key, value) ->
    obj = key
    if typeof key is 'string'
      if typeof value is 'undefined'
        return @[key]
      obj = {}
      obj[key] = value
    for own key, value of obj
      @[key] = value

  include: (type, arg...) ->
    unless Suki.Entity.definitions[type]
      throw new Error "Entity '#{type}' must be defined before created."

    {_constructor, _destructor} = Suki.Entity.definitions[type]
    _constructor.call @, arg...
    @_included[type] = _destructor
    @

  is: (type) ->
    Boolean @type is type or @_included[type]

  css: (key, value) ->
    if value is undefined
      @style[key]
    else
      unless @style[key] is value
        @style[key] = value
        @dirty = true

  destroy: (arg...) ->
    delete @scene
    for own key, destructor of @_included
      destructor.call @, arg...
    Suki.trigger 'DestroyEntity', @
    @unbind()
    @_destructor? arg...

  @definitions = {}
  @define: (type, constructor, destructor) ->
    @definitions[type] =
      _constructor: constructor or ->
      _destructor: destructor or ->
    @

  @create = (type, arg...) -> new @ type, arg...

  dirtyProperty = ['width', 'height', 'x', 'y']
  for property in dirtyProperty
    @getter property, -> @["_#{property}"]
    @setter property, (value) ->
      value = Math.round value
      unless @[property] is value
        @dirty = true
        @["_#{property}"] = value

