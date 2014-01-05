Suki = require('../build/suki.test')()

describe 'Vector', ->
  describe '#constructor', ->
    describe 'created as a circle', ->
      it 'should be a circle', ->
        circle = new Suki.Vector Suki.Vector.CIRCLE, [0, 1], 2
        circle.type.should.eql Suki.Vector.CIRCLE
        circle.center[0].should.eql 0
        circle.center[1].should.eql 1
        circle.radius.should.eql 2

    describe 'created as a polygon', ->
      it 'should be a polygon', ->
        polygon = new Suki.Vector Suki.Vector.POLYGON, [0, 0], [1, 1], [1, 0]
        polygon.type.should.eql Suki.Vector.POLYGON
        polygon.points[0].should.eql [0, 0]
        polygon.points[1].should.eql [1, 1]
        polygon.points[2].should.eql [1, 0]

    describe 'created as others', ->
      it 'should throw', ->
        (-> new Suki.Vector 'other').should.throw /must be either/

  describe '#rotate', ->
    describe 'circle', ->
      it 'should rotate around the origin', ->
        circle = new Suki.Vector Suki.Vector.CIRCLE, [0, 0], 2
        circle = circle.rotate 30, [0, 0]
        circle.center.should.eql [0, 0]
        circle.radius.should.eql 2

        circle = new Suki.Vector Suki.Vector.CIRCLE, [100, 100], 3
        circle = circle.rotate 30, [0, 0]
        circle.center.should.eql [37, 137]
        circle.radius.should.eql 3

    describe 'polygon', ->
      it 'should rotate around the origin', ->
        polygon = new Suki.Vector Suki.Vector.POLYGON, [0, 0], [100, 100], [200, 0]
        polygon = polygon.rotate 30, [0, 0]
        polygon.points[0].should.eql [0, 0]
        polygon.points[1].should.eql [37, 137]
        polygon.points[2].should.eql [173, 100]

  describe '#collided', ->
    describe 'circle vs circle', ->
      it 'should return false when the two circles are not collided', ->
        c1 = new Suki.Vector Suki.Vector.CIRCLE, [0, 0], 10
        c2 = new Suki.Vector Suki.Vector.CIRCLE, [20, 0], 10
        c1.collided(c2).should.be.false
        c2.collided(c1).should.be.false

        c1 = new Suki.Vector Suki.Vector.CIRCLE, [210, 220], 30
        c2 = new Suki.Vector Suki.Vector.CIRCLE, [151, 40], 30
        c1.collided(c2).should.be.false
        c2.collided(c1).should.be.false

      it 'should return true when the two circles are collided', ->
        c1 = new Suki.Vector Suki.Vector.CIRCLE, [0, 0], 10
        c2 = new Suki.Vector Suki.Vector.CIRCLE, [10, 0], 10
        c1.collided(c2).should.be.true
        c2.collided(c1).should.be.true

    describe 'polygon vs polygon', ->
      it 'should return false when the two polygon are not collided', ->
        p1 = new Suki.Vector Suki.Vector.POLYGON, [0, 0], [100, 100], [200, 0], [100, -100]
        p2 = new Suki.Vector Suki.Vector.POLYGON, [100, 100], [200, 0], [300, 0]
        p1.collided(p2).should.be.false
        p2.collided(p1).should.be.false

      it 'should return true when the two circles are collided', ->
        p1 = new Suki.Vector Suki.Vector.POLYGON, [0, 0], [100, 100], [200, 0], [100, -100]
        p2 = new Suki.Vector Suki.Vector.POLYGON, [100, 100], [100, 0], [0, 0]
        p1.collided(p2).should.be.true
        p2.collided(p1).should.be.true

        p1 = new Suki.Vector Suki.Vector.POLYGON, [0, 0], [0, 3], [3, 3], [3, 0]
        p2 = new Suki.Vector Suki.Vector.POLYGON, [4, 4], [4, 6], [6, 6], [6, 4]
        p1.collided(p2).should.be.false
        p2.collided(p1).should.be.false

        p1 = new Suki.Vector Suki.Vector.POLYGON, [0, 0], [0, 5], [5, 4], [3, 0]
        p2 = new Suki.Vector Suki.Vector.POLYGON, [4, 4], [4, 6], [6, 6], [6, 4]
        p1.collided(p2).should.be.true
        p2.collided(p1).should.be.true

