Suki.Entity.define 'Collision', ->
  @collision = (boundary, collisionMap) ->
    @collision.boundary = boundary
    @collision.collisionMap = collisionMap

  @bind 'beforeMove', (speed) ->
    origin =
      top: @y
      left: @x
    originSpeed =
      x: speed.x
      y: speed.y
    @x += speed.x
    @y += speed.y
    entities = @layer.entities.filter (entity) =>
      entity.is('Collision') and entity isnt @
    if typeof @collision.collisionMap is 'object'
      keys = Object.keys _collisionMap
      entities = entities.filter (entity) ->
        keys.some (key) ->
          entity.is key

    sc = {}
    if Math.abs(speed.x) > Math.abs(speed.y)
      sc.x = speed.x / (if speed.y then Math.abs(speed.y) else Math.abs(speed.x))
      sc.y = if speed.y then speed.y / Math.abs(speed.y) else 0
    else
      sc.x = if speed.x then speed.x / Math.abs(speed.x) else 0
      sc.y = speed.y / (if speed.x then Math.abs(speed.x) else Math.abs(speed.y))

    entities.some (entity) =>
      step = 0
      colliede = false
      while entity.collision.boundary.relative(entity.x, entity.y).collided @.collision.boundary.relative(@x, @y)
        console.log entity.id, speed
        console.log entity.id, 'sc', sc
        if speed.x is 0 and speed.y is 0
          break
        colliede = true
        step += 1
        speed.x = Math.round originSpeed.x - step * sc.x
        speed.y = Math.round originSpeed.y - step * sc.y
        @y = origin.top + speed.y
        @x = origin.left + speed.x
      if colliede
        speed.x = originSpeed.x
        speed.y = originSpeed.y
        @x = origin.left
        @y = origin.top
        @trigger 'hit', entity,
          currentSpeed: speed
          x: step * sc.x
          y: step * sc.y
        true

