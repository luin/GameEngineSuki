preSuki = window.Suki
Suki = window.Suki = {}

Suki.noConflict = ->
  window.Suki = preSuki
  @

Suki.trigger = (arg...)->
  Suki.Event.triggerAll arg...

