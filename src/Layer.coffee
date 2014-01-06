class Suki.Layer extends Suki.Base
  @include Suki.Timer
  @include Suki.Event

  constructor: (@type, arg...) ->
    unless Suki.Layer.definitions[@type]
      throw new Error "Layer '#{@type}' must be defined before created."

    {@_constructor, @_destructor} = Suki.Layer.definitions[@type]

    @bind 'CreateEntity', (entity) ->
      if Suki.Layer.current is @
        @entities.push entity
    @bind 'DestroyEntity', (entity) ->
      index = @entities.indexOf entity
      unless index is -1
        @entities.splice index, 1

    Suki.Layer.current = @
    @entities = []
    @x = @y = 0
    @scale = 1
    @scene = Suki.Scene.current
    Suki.trigger 'CreateLayer', @
    @_constructor arg...

  destroy: (arg...) ->
    delete @scene
    entity.destroy() for entity in @entities
    @entities = []

    Suki.trigger 'DestroyLayer', @
    @unbind()
    @_destructor? arg...

  loadTiled: (data) ->
    @width = data.width * data.tilewidth
    @height = data.height * data.tileheight
    tileSet = {}
    for tileSet in data.tilesets
      width = Math.floor tileSet.imagewidth / tileSet.tilewidth
      height = Math.floor tileSet.imageheight / tileSet.tileheight
      for x in [0..width - 1]
        for y in [0..height - 1]
          tileSet[y * width + x + tileSet.firstgid] =
            image: tileSet.image
            x: x * tileSet.tilewidth
            y: y * tileSet.tileheight
            width: tileSet.tilewidth
            height: tileSet.tileheight
            totalWidth: tileSet.imagewidth
            totalHeight: tileSet.imageheight
            tags: tileSet.tileproperties?[y * width + x]

    prevLayer = Suki.Layer.current
    Suki.Layer.current = @
    for layer in data.layers
      for data, index in layer.data
        continue unless tileSet[data]
        entity = Suki.Entity.create 'Sprite'
        entity.css 'zIndex', 1
        entity.sprite tileSet[data]
        if tileSet[data].tags and Object.keys(tileSet[data].tags).length
          entity.tag tileSet[data].tags
        entity.x = (index % layer.width) * entity.width
        entity.y = Math.floor(index / layer.width) * entity.height
        if layer.name.toLowerCase() is 'collision'
          entity.include 'Collision'
    Suki.Layer.current = prevLayer

  @definitions: {}
  @define: (type, constructor, destructor) ->
    @definitions[type] =
      _constructor: constructor or ->
      _destructor: destructor
    @
  @create: (type, arg...) ->
    new @ type, arg...

  Object.defineProperty @, 'current',
    get: ->
      unless @_current
        @create @_defaultLayerType
      @_current
    set: (layer) ->
      @_current = layer

  @clear: ->
    @definitions = {}
  @_defaultLayerType: 'SUKI_DEFAULT_LAYER'

  @define @_defaultLayerType

  dirtyProperty = ['width', 'height', 'x', 'y']
  dirtyProperty.forEach (property) =>
    @getter property, -> @["_#{property}"]
    @setter property, (value) ->
      value = Math.round value
      unless @[property] is value
        @dirty = true
        @["_#{property}"] = value

