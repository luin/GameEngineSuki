class Suki.Vector extends Suki.Base
  @POLYGON: 'POLYGON'
  @BOX: 'BOX'

  constructor: (arg...) ->
    @arg = arg
    if Array.isArray arg[0]
      @type = Suki.Vector.POLYGON
      @_points = []
      for point in arg
        @_points.push [point[0], point[1]]
      @_points = arg
    else
      @type = Suki.Vector.BOX
      [@x, @y, @width, @height] = arg

  @getter 'points', ->
    if @_points
      @_points
    else [
      [@x, @y]
      [@x + @width, @y]
      [@x + @width, @y + @height]
      [@x, @y + @height]
    ]

  collided: (other) ->
    test = (polygonA, polygonB) ->
      for currentPoint, index in polygonA.points
        nextPoint = polygonA.points[if index is polygonA.points.length - 1 then 0 else index + 1]

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

  duplicate: ->
    new Suki.Vector @arg...

  relative: ([x, y]) ->
    newVector = @duplicate()
    if newVector.type is Suki.Vector.BOX
      newVector.x += x
      newVector.y += y
    else
      for point, index in newVector.points
        newVector.points[index] = [point[0] + x, point[1] + y]
    newVector

  rotate: (deg, origin) ->
    newVector = new Suki.Vector @points...
    for point, index in newVector.points
      newVector.points[index] = Suki.Vector.rotatePoint point, deg, origin
    newVector

  @rotatePoint: (source, deg, origin) ->
    [
      Math.round source[0] * Math.cos(deg * Math.PI / 180) - source[1] * Math.sin(deg * Math.PI / 180)
      Math.round source[0] * Math.sin(deg * Math.PI / 180) + source[1] * Math.cos(deg * Math.PI / 180)
    ]


