Suki.Entity.define 'Collision', ->
  @collision = (boundary, collisionMap) ->
    @collision.boundary = new Suki.Vector 0, 0, @width, @height

  @bind 'beforeMove', (speed) ->
    entities = @layer.entities.filter (entity) =>
      entity.is('Collision') and entity isnt @

    entities.forEach (entity) =>
      result =
        overlay: { x: 0, y: 0 }
        hit: {}
      myBoundary = @collision.boundary.relative [@x, @y]
      hisBoundary = entity.collision.boundary.relative [entity.x, entity.y]

      if myBoundary.type is Suki.Vector.BOX and hisBoundary.type is Suki.Vector.BOX
        hitBox =
          x: Math.min @x, @x + speed.x
          y: Math.min @y, @y + speed.y
          width: @width + Math.abs speed.x
          height: @height + Math.abs speed.y
        isHit = hitBox.x < entity.x + entity.width and
                hitBox.x + hitBox.width > entity.x and
                hitBox.y < entity.y + entity.height and
                hitBox.y + hitBox.height > entity.y

        if isHit
          # Simple collision test
          result.hit.left = myBoundary.x + myBoundary.width <= hisBoundary.x and
                    myBoundary.x + myBoundary.width + speed.x > hisBoundary.x
          result.hit.right = myBoundary.x >= hisBoundary.x + hisBoundary.width and
                     myBoundary.x + speed.x < hisBoundary.x + hisBoundary.width
          result.hit.top = myBoundary.y + myBoundary.height <= hisBoundary.y and
                   myBoundary.y + myBoundary.height + speed.y > hisBoundary.y
          result.hit.bottom = myBoundary.y >= hisBoundary.y + hisBoundary.height and
                      myBoundary.y + speed.y < hisBoundary.y + hisBoundary.height

          if result.hit.left then result.overlay.x = myBoundary.x + myBoundary.width + speed.x - hisBoundary.x
          if result.hit.right then result.overlay.x = myBoundary.x + speed.x - hisBoundary.x - hisBoundary.width
          if result.hit.top then result.overlay.y = myBoundary.y + myBoundary.height + speed.y - hisBoundary.y
          if result.hit.bottom then result.overlay.y = myBoundary.y + speed.y - hisBoundary.y - hisBoundary.height
          result.type = 'simple'
          result.entity = entity
          @trigger 'hit', result, speed
      else
        # SAT
        throw new Error 'Not implemented SAT'

