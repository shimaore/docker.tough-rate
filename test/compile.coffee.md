    describe 'The modules', ->
      it 'should compile', ->
        process.env.CONFIG = './local/example.json'
        require '../index'
        require '../middleware/config'
        require '../middleware/server'
