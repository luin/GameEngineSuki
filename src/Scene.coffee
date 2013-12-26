class Suki.Scene extends Suki.Base
  @include Suki.Timer
  @include Suki.Event

  constructor: (type, arg...) ->
    {@_constructor, @_destructor} = Suki.Scene.definitions[type]

    unless constructor
      throw new Error "Scene '#{type}' must be defined before create."

    @_entities = []
    @bind 'NewEntity', (entity) ->
      console.log(entity)
      @_entities.push entity if Suki.Scene.current is @

  start: (arg...)->
    setTimeout =>
      Suki.Scene.current = @
      @_constructor arg...
      @frameTimer = new Suki.Timer =>
        @enterFrame()
      , 20, Infinity
      @bind 'AfterDraw', ->
        @_entities.forEach (entity) ->
          entity._dirty = false
    , 0
  enterFrame: ->
    Suki.trigger 'EnterFrame'
    Suki.trigger 'BeforeDraw', @_entities

  @definitions = {}
  @define = (type, constructor, destructor) ->
    @definitions[type] =
      _constructor: constructor
      _destructor: destructor

  Object.defineProperty @, 'current',
    get: ->
      unless @_current
        throw new Error "Entities must be created inside a scene."
      @_current
    set: (newScene) ->
      Suki.trigger 'BeforeSceneChange', @_current, newScene
      if @_current
        @_current.trigger 'beforeSceneDestory'
        @_current.destory()
      @_current = newScene
