Suki = require('../build/suki.test')()

describe 'Layer', ->
  before ->
    Suki.Layer.define 'Layer1'

  describe '.current', ->
    describe 'without any layers active', ->
      it 'should create a new layer', ->
        layer = Suki.Layer.current
        layer.should.be.an.instanceof Suki.Layer
        layer.type is Suki.Layer._defaultLayerType

    describe 'with at least one scene beening active', ->
      it 'should return the last created layer', ->
        layer = Suki.Layer.create 'Layer1'
        Suki.Layer.current.should.eql layer

  describe '.create', ->
    describe 'when has not been defined', ->
      it 'should throw when the type of scene has not been defined', ->
        (-> Suki.Scene.create 'NoSuchType').should.throw /before created/

    describe 'when has been defined', ->
      it 'should trigger a global event `CreateLayer`', (done) ->
        event = new Suki.Event()
        event.one 'CreateLayer', ->
          done()
        layer = Suki.Layer.create 'Layer1'

  describe '#destroy', ->
    it 'should trigger a global event `DestroyLayer`', (done) ->
      event = new Suki.Event()
      event.one 'DestroyLayer', ->
        done()
      Suki.Layer.current.destroy()
