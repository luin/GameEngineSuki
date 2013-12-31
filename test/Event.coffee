Suki = require('../build/suki.test')()

describe 'Event', ->
  describe '#bind', ->
    it 'should only reply to the events belongs to itself', ->
      count = 0
      event1 = new Suki.Event()
      event1.bind 'Event', -> count++

      event1.trigger 'Event'
      event1.trigger 'Event'

      event2 = new Suki.Event()
      event2.trigger 'Event'

      count.should.eql 2

    it 'should reply to the global events', ->
      count = 0
      event = new Suki.Event()
      event.bind 'Event', -> count++

      Suki.trigger 'Event'
      Suki.trigger 'Event'

      count.should.eql 2

  describe '#unbind', ->
    it 'should remove all handers when the eventType and handler are not specified', ->
      count = 0
      event = new Suki.Event()
      event.bind 'Event1', -> count += 1
      event.bind 'Event2', -> count += 2
      event.bind 'Event3', -> count += 4

      event.unbind()

      Suki.trigger 'Event1'
      Suki.trigger 'Event2'
      Suki.trigger 'Event3'

      count.should.eql 0

    it 'should remove all handers belong to the specified eventType', ->
      count = 0
      event = new Suki.Event()
      event.bind 'Event1', -> count += 1
      event.bind 'Event1', -> count += 1
      event.bind 'Event2', -> count += 2
      event.bind 'Event3', -> count += 4

      event.unbind 'Event1'

      Suki.trigger 'Event1'
      Suki.trigger 'Event2'
      Suki.trigger 'Event3'

      count.should.eql 6

    describe 'internal', ->
      it 'should delete the handlers list when the list is empty', ->
        event = new Suki.Event()
        event.bind 'InternalEvent', ->
        Suki.Event._handlers['InternalEvent'].should.have.lengthOf 1
        event.unbind()
        (typeof Suki.Event._handlers['InternalEvent']).should.eql 'undefined'

    it 'should remove the specified handers', ->
      count = 0
      handler = -> count += 1

      event1 = new Suki.Event()
      event1.bind 'Event1', handler
      event1.bind 'Event1', handler
      event1.bind 'Event2', -> count += 2
      event1.bind 'Event3', -> count += 4
      event1.bind 'Event1', -> count += 8

      event2 = new Suki.Event()
      event2.bind 'Event1', handler

      event1.unbind 'Event1', handler

      Suki.trigger 'Event1'
      Suki.trigger 'Event2'
      Suki.trigger 'Event3'

      count.should.eql 15

  describe '#one', ->
    it 'should reply only once', ->
      count = 0

      event = new Suki.Event()
      event.one 'Event', -> count += 1

      Suki.trigger 'Event'
      Suki.trigger 'Event'

      count.should.eql 1

