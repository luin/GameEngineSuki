Suki.Entity.define 'Gravity', ->
  @gravity = (g) ->
    speed = 0
    @bind 'hit', (e, curSpeed) ->
      g = 0
      speed = 0
      curSpeed.y -= e.overlay.y
    @bind 'EnterFrame', ->
      speed += g
      @frameSpeed.y += speed
