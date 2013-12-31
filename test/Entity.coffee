Suki = require('../build/suki.test')()

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
      boy.css 'backgroundColor', '#123456'
      boy.dirty.should.be.true

  describe '#id', ->
    it 'should contain `Entity`', ->
      boy = new Suki.Entity 'Boy'
      boy.id.should.include 'Entity'

  describe '#constructor', ->
    it 'should trigger a global event `CreateEntity`', (done) ->
      event = new Suki.Event()
      event.one 'CreateEntity', (e) ->
        e.gender.should.eql 'girl'
        done()
      Suki.Entity.define 'Girl', ->
        @gender = 'girl'
      new Suki.Entity 'Girl'

  describe '#destroy', ->
    it 'should call the `_destructor` method when destroyed', (done) ->
      Suki.Entity.define 'TestDestroy', null, ->
        done()
      entity = Suki.Entity.create 'TestDestroy'
      entity.destroy()

    it 'should unbind all events', ->
      boy = Suki.Entity.create 'Boy'
      boy.bind 'Happy', ->
      count = Suki.trigger 'Happy'
      count.should.eql 1
      boy.destroy()
      count = Suki.trigger 'Happy'
      count.should.eql 0

  describe '#is', ->
    it 'should return true if the type is correct', ->
      boy = Suki.Entity.create 'Boy'
      boy.is('Boy').should.be.true

    it 'should return true if the type is wrong', ->
      boy = Suki.Entity.create 'Boy'
      boy.is('Girl').should.be.false

  describe '#include', ->
    it 'should extends the object', ->
      Suki.Entity.define 'Goddess', ->
        @include 'Girl'
      goddess = Suki.Entity.create 'Goddess'
      goddess.gender.should.eql 'girl'

    describe '#is', ->
      it 'should return true when the type is included', ->
        Suki.Entity.define 'Goddess', ->
          @include 'Girl'
        goddess = Suki.Entity.create 'Goddess'
        goddess.is('Girl').should.be.true

    describe '#destroy', ->
      it 'should also destroy the entites been included', ->
        destroyCount = 0
        Suki.Entity.define 'BeIncluded', null, ->
          destroyCount++

        Suki.Entity.define 'TestIncludedDestroy', ->
          @include 'BeIncluded'
        , ->
          destroyCount++

        entity = Suki.Entity.create 'TestIncludedDestroy'
        entity.destroy()
        destroyCount.should.eql 2

  describe '.define', ->
    it 'should be able to redefine a entity', ->
      Suki.Entity.define 'Boy', ->
        @gender = 'boy'
      boy = new Suki.Entity 'Boy'
      boy.gender.should.eql 'boy'

  describe '.create', ->
    it 'should return a new instance', (done) ->
      event = new Suki.Event()
      event.one 'CreateEntity', (e) ->
        e.gender.should.eql 'girl'
        done()
      Suki.Entity.define 'Girl', ->
        @gender = 'girl'
      girl = Suki.Entity.create 'Girl'
      girl.should.be.an.instanceof Suki.Entity

