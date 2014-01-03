class Suki.Vector extends Suki.Base
  constructor: (@type, arg...) ->
    if @type is Suki.Vector.CIRCLE
      @center = [arg[0][0], arg[0][1]]
      @radius = arg[1]
    else if @type is Suki.Vector.POLYGON
      @points = arg
    else
      throw new Error '`type` must be either `Suki.Vector.CIRCLE` or `Suki.Vector.POLYGON`'

  collided: (other) ->
    if @type is Suki.Vector.CIRCLE and other.type is Suki.Vector.CIRCLE
      totalRadius = @radius + other.radius
      x = @center[0] - other.center[0]
      y = @center[1] - other.center[1]
      distance = Math.sqrt(x * x + y * y)
      distance < totalRadius
    # else if @type is Suki.Vector.CIRCLE and other.type is Suki.Vector.POLYGON
    # else if @type is Suki.Vector.POLYGON and other.type is Suki.Vector.CIRCLE
    else if @type is Suki.Vector.POLYGON and other.type is Suki.Vector.POLYGON
      test = (polygonA, polygonB) ->
        for currentPoint, index in polygonA.points
          nextPoint = polygonA.points[if index is polygonA.points.length-1 then 0 else index+1]

          normal = [currentPoint[1] - nextPoint[1], nextPoint[0] - currentPoint[0]]
          length = Math.sqrt normal[0] * normal[0] + normal[1] * normal[1]
          normal[0] /= length
          normal[1] /= length

          minA = minB = Infinity
          maxA = maxB = -Infinity

          for point in polygonA.points
            dot = point[0] * normal[0] + point[1] * normal[1]
            maxA = dot if dot > maxA
            minA = dot if dot < minA

          for point in polygonB.points
            dot = point[0] * normal[0] + point[1] * normal[1]
            maxB = dot if dot > maxB
            minB = dot if dot < minB

          if minA < minB
            interval = minB - maxA
          else
            interval = minA - maxB

          unless interval < 0
            return true

      not test(@, other) and not test(other, @)

  @CIRCLE = 'c'
  @POLYGON = 'p'

  duplicate: ->
    if @type is Suki.Vector.CIRCLE
      new Suki.Vector @type, @center, @radius
    else
      new Suki.Vector @type, @points...

  relative: (x, y) ->
    newVector = @duplicate()
    if @type is Suki.Vector.CIRCLE
      newVector.center = [newVector.center[0] + x, newVector.center[1] + y]
    else
      for point, index in newVector.points
        newVector.points[index] = [point[0] + x, point[1] + y]
    newVector

  rotate: (deg, origin) ->
    newVector = @duplicate()
    if @type is Suki.Vector.CIRCLE
      newVector.center = Suki.Vector.rotatePoint newVector.center, deg, origin
    else
      for point, index in newVector.points
        newVector.points[index] = Suki.Vector.rotatePoint point, deg, origin
    newVector

  @rotatePoint: (source, deg, origin) ->
    [
      Math.round source[0] * Math.cos(deg * Math.PI / 180) - source[1] * Math.sin(deg * Math.PI / 180)
      Math.round source[0] * Math.sin(deg * Math.PI / 180) + source[1] * Math.cos(deg * Math.PI / 180)
    ]


