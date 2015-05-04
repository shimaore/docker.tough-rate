    describe 'The modules', ->
      it 'should compile config', ->
        process.env.CONFIG = './local/example.json'
        require '../middleware/config'

      it 'should compile server', ->
        require '../middleware/server'

      it 'should run', ->
        process.env.CONFIG = './local/example.json'
        process.env.MODE = 'config'
        require '../index'
        null
