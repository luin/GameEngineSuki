if typeof window isnt 'undefined'
  preSuki = window.Suki
  Suki = window.Suki = {}

  Suki.noConflict = ->
    window.Suki = preSuki
    @
else
  window = {}
  Suki = {}

Suki.trigger = (arg...)->
  Suki.Event.triggerAll arg...

module?.exports = Suki
