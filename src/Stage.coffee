class Suki.Stage extends Suki.Base
  @include Suki.Event

  constructor: (width = 926.4, height = 246.4, canvas)->
    if typeof canvas is 'string'
      canvas = document.getElementById element
      unless canvas
        throw new Error "Could't find the element by id #{canvas}"

    if canvas
      ELEMENT_TYPE = HTMLElement || Element
      unless canvas instanceof ELEMENT_TYPE
        throw new TypeError '`canvas` must be a string or an HTMLElement'
    else
      canvas = document.createElement 'div'
      canvas.id = @UUID()
      document.body.appendChild canvas

    pCanvas = @canvas =
      dom: canvas
      scale: {}
      scroll: {}

    ['x', 'y'].forEach (property) =>
      Object.defineProperty @canvas.scale, property,
        get: -> @["_#{property}"]
        set: (value) ->
          pCanvas._dirty = pCanvas._deepDirty = true
          @["_#{property}"] = value

    ['x', 'y'].forEach (property) =>
      Object.defineProperty @canvas.scroll, property,
        get: -> @["_#{property}"]
        set: (value) ->
          pCanvas._dirty = true
          @["_#{property}"] = value

    ['width', 'height'].forEach (property) =>
      Object.defineProperty @canvas, property,
        get: -> @["_#{property}"]
        set: (value) ->
          @._dirty = true
          @["_#{property}"] = value

    @canvas.scale.x = 1
    @canvas.scale.y = 1
    @canvas.scroll.x = 0
    @canvas.scroll.y = 0
    @canvas.width = width
    @canvas.height = height

    @bind 'BeforeDraw', (entities) ->
      if @canvas._dirty
        @canvas.dom.style.left += "#{@canvas.scroll.x}px"
        @canvas.dom.style.top += "#{@canvas.scroll.y}px"
        @canvas.dom.style.width = "#{@canvas.width * @canvas.scale.x}px"
        @canvas.dom.style.height = "#{@canvas.height * @canvas.scale.y}px"
        @canvas._dirty = false

      entities.forEach (entity) =>
        unless @canvas._deepDirty or entity._dirty
          return

        element = document.getElementById entity.id
        unless element
          element = document.createElement 'div'
          element.id = entity.id
          element.style.position = 'absolute'
          @canvas.dom.appendChild element
        element.style.left = "#{entity.x * @canvas.scale.x}px"
        element.style.top = "#{entity.y * @canvas.scale.y}px"
        element.style.width = "#{entity.width * @canvas.scale.x}px"
        element.style.height = "#{entity.height * @canvas.scale.y}px"
        for own key, value of entity.style
          element.style[key] = value

      @canvas._deepDirty = false
      Suki.trigger 'AfterDraw', entities

