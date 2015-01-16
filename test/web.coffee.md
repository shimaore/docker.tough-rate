    chai = require 'chai'
    chai.use require 'chai-as-promised'
    chai.should()
    request = require 'superagent-as-promised'

    describe 'Basic web service', ->
      app = null
      before ->
        options =
          web:
            port: 5704
        app = (require '../web') options, null # no server
      after ->
        app.server?.close()

      it 'should respond', (done) ->
        request.get 'http://127.0.0.1:5704/'
        .then ({body}) ->
          body.should.have.property 'ok', true
          body.should.have.property 'version'
          done()

