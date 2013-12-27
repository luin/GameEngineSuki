Suki = require '../build/suki.coffee'

describe 'Entity', ->
  beforeEach ->
    Suki.Entity.define 'Boy', ->

  describe '#attr', ->
    it 'should accept a key/value pair', ->
      boy = new Suki.Entity 'Boy'
      boy.attr 'name', 'Jeff'
      boy.name.should.eql 'Jeff'

    it 'should accept a object', ->
      boy = new Suki.Entity 'Boy'
      boy.attr
        name: 'Jeff'
        age: 28
      boy.name.should.eql 'Jeff'
      boy.age.should.eql 28

    it 'should return the attribute when the value is omitted', ->
      boy = new Suki.Entity 'Boy'
      boy.attr 'name', 'Jeff'
      name = boy.attr 'name'
      name.should.eql 'Jeff'

  describe '#css', ->
    it 'should set the `style`', ->
      boy = new Suki.Entity 'Boy'
      boy.css 'backgroundColor', '#CCC'
      boy.style.backgroundColor.should.eql '#CCC'

    it 'should return the style when the value is omitted', ->
      boy = new Suki.Entity 'Boy'
      boy.css 'backgroundColor', '#CCC'
      backgroundColor = boy.css 'backgroundColor'
      backgroundColor.should.eql '#CCC'

    it 'should get the entity dirty', ->
      boy = new Suki.Entity 'Boy'
      boy.css 'backgroundColor', '#CCC'
      boy.dirty.should.be.true

  describe '#id', ->
    it 'should contain `Entity`', ->
      boy = new Suki.Entity 'Boy'
      boy.id.should.include 'Entity'

  describe '#constructor', ->
    it 'should trigger a global event `NewEntity`', (done) ->
      event = new Suki.Event()
      event.bind 'NewEntity', (e) ->
        e.gender.should.eql 'girl'
        event.unbind 'NewEntity'
        done()
      Suki.Entity.define 'Girl', ->
        @gender = 'girl'
      new Suki.Entity 'Girl'

  describe '#include', ->
    it 'should extends the object', ->
      Suki.Entity.define 'Goddess', ->
        @include 'Girl'
      goddess = new Suki.Entity 'Goddess'
      goddess.gender.should.eql 'girl'

  describe '.define', ->
    it 'should be able to redefine a entity', ->
      Suki.Entity.define 'Boy', ->
        @gender = 'boy'
      boy = new Suki.Entity 'Boy'
      boy.gender.should.eql 'boy'
