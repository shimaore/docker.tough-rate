    chai = require 'chai'
    chai.use require 'chai-as-promised'
    chai.should()
    request = require 'superagent-as-promised'

    describe 'Basic web service', ->
      app = null
      before ->
        CaringBand = require 'caring-band'
        options =
          web:
            port: 5704
        statistics = new CaringBand()
        app = (require '../web') options, {statistics}
        statistics.add 'foo', 2
      after ->
        app.server?.close()

      it 'should respond', (done) ->
        request.get 'http://127.0.0.1:5704/'
        .then ({body}) ->
          body.should.have.property 'ok', true
          body.should.have.property 'version'
          done()

      it 'should provide all statistics', (done) ->
        request.get 'http://127.0.0.1:5704/statistics'
        .then ({body}) ->
          body.should.have.property 'foo'
          body.foo.should.have.property 'count', 1
          done()

