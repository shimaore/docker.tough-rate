    describe 'The modules', ->
      it 'should compile config', ->
        process.env.CONFIG = './test/example.json'
        require '../middleware/config'

      it 'should compile server', ->
        require '../middleware/server'

      it 'should run', ->
        process.env.CONFIG = './test/example.json'
        process.env.MODE = 'config'
        process.env.SUPERVISOR = ''
        require '../index'
        null
