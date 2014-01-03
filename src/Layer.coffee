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
    @_constructor arg...
    @scene = Suki.Scene.current
    Suki.trigger 'CreateLayer', @

  destroy: (arg...) ->
    delete @scene
    entity.destroy() for entity in @entities
    @entities = []

    Suki.trigger 'DestroyLayer', @
    @unbind()
    @_destructor? arg...

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
