class Suki.Timer extends Suki.Base
  @include Suki.Event

  constructor: (step, interval, repeat, useRequestAnimationFrame = true) ->
    @meta =
      beginTime: Date.now()
      count: 0
      repeat: repeat
    beginTick = =>
      if useRequestAnimationFrame and Suki.Timer.requestAnimationFrame
        tick = =>
          passedTime = @meta.count * interval
          timeSlot = Date.now() - passedTime - @meta.beginTime
          passedCount = Math.floor timeSlot / interval
          while passedCount && @meta.repeat
            step()
            ++@meta.count
            --@meta.repeat
            --passedCount
          if @meta.repeat
            Suki.Timer.requestAnimationFrame.call window, tick
        tick()
      else
        @timer = setInterval =>
          if @meta.repeat and not @paused
            step()
            --@meta.repeat
          else
            clearInterval @timer
    @bind 'Pause', ->
      @paused = true

    @bind 'Unpause', ->
      @paused = true

    beginTick()

  delay: (step, interval) ->
    return new Suki.Timer step, interval, 1

  destructor: ->
    @unbind 'Unpause'
    @unbind 'Pause'
    @paused = true

  @requestAnimationFrame =
    window.requestAnimationFrame or
    window.webkitRequestAnimationFrame or
    window.mozRequestAnimationFrame or
    window.oRequestAnimationFrame or
    window.msRequestAnimationFrame
