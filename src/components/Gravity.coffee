Suki.Entity.define 'Gravity', ->
  speedY = 0
  gy = 0.03
  @gravity = ->
    @bind 'EnterFrame', ->
      if speedY < 1
        speedY += gy
        @frameSpeed.y += speedY
