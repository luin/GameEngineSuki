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
      document.body.appendChild camera

    pCanvas = @camera =
      dom: camera
      scale: {}
      scroll: {}

    ['x', 'y'].forEach (property) =>
      Object.defineProperty @camera.scale, property,
        get: -> @["_#{property}"]
        set: (value) ->
          pCanvas.dirty = true
          for layer in Suki.Scene.current.layers
            layer.deepDirty = true
          @["_#{property}"] = value

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

    @camera.scale.x = 1
    @camera.scale.y = 1
    @camera.scroll.x = 0
    @camera.scroll.y = 0
    @camera.width = width
    @camera.height = height

    @bind 'DrawCamera', ->
      if @camera.dirty
        @camera.dom.style.width = "#{@camera.width * @camera.scale.x}px"
        @camera.dom.style.height = "#{@camera.height * @camera.scale.y}px"
        @camera.dirty = false

    @bind 'DrawLayer', (layer) ->
      if layer.dirty
        layerElement = document.getElementById layer.id
        scroll =
          x: @camera.scroll.x
          y: @camera.scroll.y
        layer.trigger 'scroll', scroll
        layerElement.style.left = -"#{scroll.x}px"
        layerElement.style.top = -"#{scroll.y}px"
        layer.dirty = false

      for entity in layer.entities
        if layer.deepDirty or entity.dirty
          element = document.getElementById entity.id
          element.style.left = "#{entity.x * @camera.scale.x}px"
          element.style.top = "#{entity.y * @camera.scale.y}px"
          element.style.width = "#{entity.width * @camera.scale.x}px"
          element.style.height = "#{entity.height * @camera.scale.y}px"
          for own key, value of entity.style
            element.style[key] = value

          entity.dirty = false

      layer.deepDirty = false

    @bind 'CreateEntity', (entity) ->
      element = document.createElement 'div'
      element.id = entity.id
      element.style.position = 'absolute'
      layerElement = document.getElementById entity.layer.id
      layerElement.appendChild element

    @bind 'CreateLayer', (layer) ->
      layerElement = document.createElement 'div'
      layerElement.id = layer.id
      layerElement.style.position = 'absolute'
      layerElement.style.left = '0'
      layerElement.style.top = '0'
      layerElement.style.width = '100%'
      layerElement.style.height = '100%'
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
