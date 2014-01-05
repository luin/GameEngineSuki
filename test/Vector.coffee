Suki = require('../build/suki.test')()

describe 'Vector', ->
  describe '#constructor', ->
    describe 'created as a box', ->
      it 'should be a box', ->
        box = new Suki.Vector 0, 5, 10, 20
        box.type.should.eql Suki.Vector.BOX
        box.points[0].should.eql [0, 5]
        box.points[1].should.eql [10, 5]
        box.points[2].should.eql [10, 25]
        box.points[3].should.eql [0, 25]

    describe 'created as a polygon', ->
      it 'should be a polygon', ->
        polygon = new Suki.Vector [0, 0], [1, 1], [1, 0]
        polygon.type.should.eql Suki.Vector.POLYGON
        polygon.points[0].should.eql [0, 0]
        polygon.points[1].should.eql [1, 1]
        polygon.points[2].should.eql [1, 0]

  describe '#rotate', ->
    describe 'polygon', ->
      it 'should rotate around the origin', ->
        polygon = new Suki.Vector [0, 0], [100, 100], [200, 0]
        polygon = polygon.rotate 30, [0, 0]
        polygon.points[0].should.eql [0, 0]
        polygon.points[1].should.eql [37, 137]
        polygon.points[2].should.eql [173, 100]

  describe '#collided', ->
    describe 'polygon vs polygon', ->
      it 'should return false when the two polygon are not collided', ->
        p1 = new Suki.Vector [0, 0], [100, 100], [200, 0], [100, -100]
        p2 = new Suki.Vector [100, 100], [200, 0], [300, 0]
        p1.collided(p2).should.be.false
        p2.collided(p1).should.be.false

      it 'should return true when the two circles are collided', ->
        p1 = new Suki.Vector [0, 0], [100, 100], [200, 0], [100, -100]
        p2 = new Suki.Vector [100, 100], [100, 0], [0, 0]
        p1.collided(p2).should.be.true
        p2.collided(p1).should.be.true

        p1 = new Suki.Vector [0, 0], [0, 3], [3, 3], [3, 0]
        p2 = new Suki.Vector [4, 4], [4, 6], [6, 6], [6, 4]
        p1.collided(p2).should.be.false
        p2.collided(p1).should.be.false

        p1 = new Suki.Vector [0, 0], [0, 5], [5, 4], [3, 0]
        p2 = new Suki.Vector [4, 4], [4, 6], [6, 6], [6, 4]
        p1.collided(p2).should.be.true
        p2.collided(p1).should.be.true

  describe '#relative', ->
    describe 'box', ->
      it 'should move the vector relative to the given point', ->
        box = new Suki.Vector 0, 0, 15, 25
        boxNew = box.relative [10, 20]
        boxNew.type.should.eql Suki.Vector.BOX
        boxNew.x.should.eql 10
        boxNew.y.should.eql 20
        boxNew.width.should.eql 15
        boxNew.height.should.eql 25

