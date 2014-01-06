class Suki.Scene extends Suki.Base
  @include Suki.Timer
  @include Suki.Event

  constructor: (@type, arg...) ->
    unless Suki.Scene.definitions[@type]
      throw new Error "Scene '#{@type}' must be defined before created."

    {@_constructor, @_destructor} = Suki.Scene.definitions[@type]

    @bind 'CreateLayer', (layer) ->
      if Suki.Scene.current is @
        @layers.push layer
    @bind 'DestroyLayer', (layer) ->
      index = @layers.indexOf layer
      unless index is -1
        @layers.splice index, 1

    @layers = []
    Suki.Scene.current = @
    @_constructor arg...
    Suki.trigger 'CreateScene', @

    @frameTimer = new Suki.Timer =>
      @enterFrame()
    , 16, Infinity

  destroy: (arg...) ->
    @frameTimer.destroy()
    layer.destroy() for layer in @layers
    @layers = []

    Suki.trigger 'DestroyScene', @
    @unbind()
    @_destructor? arg...

  enterFrame: ->
    Suki.trigger 'BeforeEnterFrame'
    Suki.trigger 'EnterFrame'
    Suki.trigger 'BeforeDraw'
    for layer in @layers
      Suki.trigger 'DrawLayer', layer
    Suki.trigger 'DrawCamera'
    Suki.trigger 'AfterDraw'

  @definitions: {}
  @define: (type, constructor, destructor) ->
    @definitions[type] =
      _constructor: constructor or ->
      _destructor: destructor or ->
    @
  @create: (type, arg...) ->
    new @ type, arg...

  Object.defineProperty @, 'current',
    get: ->
      unless @_current
        @create @_defaultSceneType
      @_current
    set: (newScene) ->
      if @_current
        @_current.destroy()
      @_current = newScene

  @clear: ->
    @definitions = {}
  @_defaultSceneType: 'SUKI_DEFAULT_SCENE'

  @define @_defaultSceneType
