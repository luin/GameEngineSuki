Suki.Entity.define 'Gravity', ->
  @gravity = (g) ->
    speed = 0
    @bind 'EnterFrame', ->
      speed += g
      @frameSpeed.y += speed
