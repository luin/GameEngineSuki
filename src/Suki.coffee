Suki = window.Suki = {}

Suki.trigger = (arg...)->
  Suki.Event.triggerAll arg...

Object.defineProperty Suki, 'stage',
  get: ->
    unless Suki._stage
      Suki._stage = new Suki.Stage()
    Suki._stage

