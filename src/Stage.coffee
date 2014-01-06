class Suki.Stage extends Suki.Base
  @include Suki.Event

  constructor: (width, height, camera) ->
    if typeof camera is 'string'
      camera = document.getElementById element
      unless camera
        throw new Error "Could't find the element by id #{camera}"

    if camera
      ELEMENT_TYPE = HTMLElement || Element
      unless camera instanceof ELEMENT_TYPE
        throw new TypeError '`camera` must be a string or an HTMLElement'
    else
      camera = document.createElement 'div'
      camera.id = @id
      camera.style.overflow = 'hidden'
      camera.style.position = 'absolute'
      document.body.appendChild camera

    pCanvas = @camera =
      dom: camera
      scale: {}
      scroll: {}

    Object.defineProperty @camera, 'scale',
      get: -> @_scale
      set: (value) ->
        pCanvas.dirty = true
        for layer in Suki.Scene.current.layers
          layer.dirty = true
          layer.deepDirty = true
        @_scale = value

    ['x', 'y'].forEach (property) =>
      Object.defineProperty @camera.scroll, property,
        get: -> @["_#{property}"]
        set: (value) ->
          pCanvas.dirty = true
          for layer in Suki.Scene.current.layers
            layer.dirty = true
          @["_#{property}"] = value

    ['width', 'height'].forEach (property) =>
      Object.defineProperty @camera, property,
        get: -> @["_#{property}"]
        set: (value) ->
          @dirty = true
          @["_#{property}"] = value

    @camera.scale = 1
    @camera.scroll.x = 0
    @camera.scroll.y = 0
    @camera.width = width
    @camera.height = height

    @bind 'DrawCamera', ->
      if @camera.dirty
        @camera.dom.style.width = "#{@camera.width * @camera.scale}px"
        @camera.dom.style.height = "#{@camera.height * @camera.scale}px"
        @camera.dirty = false

    @bind 'DrawLayer', (layer) ->
      if layer.dirty
        layerElement = document.getElementById layer.id
        scroll =
          x: @camera.scroll.x
          y: @camera.scroll.y
        layer.trigger 'scroll', scroll
        layerElement.style.left = -"#{(scroll.x + layer.x * layer.scale) * @camera.scale}px"
        layerElement.style.top = -"#{(scroll.y + layer.y * layer.scale) * @camera.scale}px"
        layerElement.style.width = if layer.width then "#{layer.width * layer.scale * @camera.scale}px" else '100%'
        layerElement.style.height = if layer.height then "#{layer.height * layer.scale * @camera.scale}px" else '100%'
        layer.dirty = false

      for entity in layer.entities
        if layer.deepDirty or entity.dirty
          element = document.getElementById entity.id
          element.style.left = "#{entity.x * layer.scale * @camera.scale}px"
          element.style.top = "#{entity.y * layer.scale * @camera.scale}px"
          element.style.width = "#{entity.width * layer.scale * @camera.scale}px"
          element.style.height = "#{entity.height * layer.scale * @camera.scale}px"
          for own key, value of entity.style
            element.style[key] =
              if layer.scale * @camera.scale is 1
                value
              else
                value.replace /(\d+)px/g, (_, number) => "#{layer.scale * @camera.scale * Number number}px"

          entity.dirty = false

      layer.deepDirty = false

    @bind 'CreateEntity', (entity) ->
      element = document.createElement 'div'
      element.id = entity.id
      element.style.position = 'absolute'
      element.style.zIndex = 10
      layerElement = document.getElementById entity.layer.id
      layerElement.appendChild element

    @bind 'CreateLayer', (layer) ->
      layerElement = document.createElement 'div'
      layerElement.id = layer.id
      layerElement.style.position = 'absolute'
      layerElement.style.left = '0'
      layerElement.style.top = '0'
      layerElement.style.overflow = 'hidden'
      @camera.dom.appendChild layerElement

  clear: ->
    @camera.innerHTML = '';

  removeEntity: (entity) ->
    element = document.getElementById entity.id
    if element
      @camera.dom.removeClild element

  removeLayer: (layer) ->
    layerElement = document.getElementById layer.id
    @camera.dom.removeClild layerElement

