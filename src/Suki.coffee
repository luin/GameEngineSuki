Suki = window.Suki = {}

Suki.trigger = (arg...) ->
  Suki.Event.triggerAll arg...

Suki.init = (width, height) ->
  Suki.stage = new Suki.Stage(width, height)

