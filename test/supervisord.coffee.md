    Promise = require 'bluebird'
    supervisord = require 'supervisord'

    chai = require 'chai'
    chai.should()

    it 'supervisordAsync should be a promise', ->
      client = Promise.promisifyAll supervisord.connect()
      client.should.have.property 'startProcessAsync'
      foo = client.startProcessAsync 'foo'
      foo.should.have.property 'then'
