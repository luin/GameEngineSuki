class Suki.Event extends Suki.Base
  trigger: (eventType, arg...) ->
    Suki.Event._handlers[eventType]?.filter (item) =>
      item.caller is @
    .forEach (item) ->
      item.handler.call item.caller, arg...

  bind: (eventType, handler) ->
    Suki.Event._handlers[eventType] = [] unless Suki.Event._handlers[eventType]
    Suki.Event._handlers[eventType].push
      caller: @
      handler: handler

  unbind: (eventType, handler) ->
    Suki.Event._handlers = Suki._handlers.filter (item) ->
        item.caller isnt @

  once: (eventType, handler) ->
    wrapperHandler = (args...) ->
      @unbind eventType, wrapperHandler
      handler.call @, args...

    @bind eventType, wrapperHandler

  @_handlers = []
  @triggerAll: (eventType, arg...) =>
    @_handlers[eventType]?.forEach (item) ->
      item.handler.call item.caller, arg...
