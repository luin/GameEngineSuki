class Suki.Event extends Suki.Base
  trigger: (eventType, arg...) ->
    Suki.Event._handlers[eventType]?.filter (item) =>
      item.caller is @
    .forEach (item) ->
      item.handler.call item.caller, arg...
    @

  bind: (eventType, handler) ->
    Suki.Event._handlers[eventType] = [] unless Suki.Event._handlers[eventType]
    Suki.Event._handlers[eventType].push
      caller: @
      handler: handler
    @

  unbind: (eventType, handler) ->
    for own _eventType, _handlers of Suki.Event._handlers
      unless eventType and eventType isnt _eventType
        for index in [_handlers.length-1..0] by -1
          item = _handlers[index]
          if item.caller is @
            unless handler and handler isnt item.handler
              _handlers.splice index, 1
    @

  one: (eventType, handler) ->
    wrapperHandler = (args...) ->
      @unbind eventType, wrapperHandler
      handler.call @, args...

    @bind eventType, wrapperHandler
    @

  @_handlers = []
  @triggerAll: (eventType, arg...) =>
    if @_handlers[eventType]
      @_handlers[eventType].forEach (item) ->
        item.handler.call item.caller, arg...
      @_handlers[eventType].length
    else
      0

