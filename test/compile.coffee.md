    describe 'The modules', ->
      it 'should compile', ->
        process.env.CONFIG = './local/example.json'
        process.env.MODE = 'config'
        require '../index'
        require '../middleware/config'
        require '../middleware/server'
