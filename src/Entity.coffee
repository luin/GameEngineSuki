class Suki.Entity extends Suki.Base
  @include Suki.Timer

  constructor: (type, arg...) ->
    constructor = Suki.Entity.definitions[type]
    unless constructor
      throw new Error "Component '#{type}' must be defined before create."

    @id = @UUID()
    @style = {}
    constructor.call @, arg...
    Suki.trigger 'NewEntity', @


  attr: (key, value) ->
    obj = key
    if typeof key is 'string'
      obj = {}
      obj[key] = value
    for own key, value of obj
      @[key] = value

  include: (type, arg...) ->
    constructor = Suki.Entity.definitions[type]
    unless constructor
      throw new Error "Component '#{type}' must be defined before create."

    constructor.call @, arg...

  css: (key, value) ->
    if value is undefined
      @style[key]
    else
      console.log key
      console.log value
      @style[key] = value
      @_dirty = true


  @definitions = {}
  @define = (type, constructor) ->
    @definitions[type] = constructor

  dirtyProperty = ['width', 'height', 'x', 'y']
  dirtyProperty.forEach (property) =>
    @getter property, -> @["_#{property}"]
    @setter property, (value) ->
      value = Math.round value
      @_dirty = true unless @[property] is value
      @["_#{property}"] = value

