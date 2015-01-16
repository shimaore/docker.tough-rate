
    Zappa = require 'zappajs'
    supervisord = require 'supervisord'
    pkg = require './package.json'
    Promise = require 'bluebird'

    module.exports = (options,server) ->

      sup = ->
        Promise.promisifyAll supervisord.connect 'http://127.0.0.1:5700'

      web = Zappa.run options.web, ->
        @get '/statistics/:key', ->
          @res.type 'json'
          value = server.statistics.get @params.key
          if value?
            @send value.toJSON()
          else
            @res.status(500).json error:'No such key', key:@params.key

        @get '/', ->
          @json
            ok:true
            package: pkg.name
            version: pkg.version
            uptime: process.uptime()
            memory: process.memoryUsage()

        @get '/supervisor', ->
          supervisor = sup()
          res = {}
          supervisor.getSupervisorVersionAsync()
          .then (version) ->
            res.version = version
            supervisor.getStateASync()
          .then (state) ->
            res.state = state
            supervisor.getAllProcessInfoAsync()
          .then (processes) ->
            res.processes = processes
          .then =>
            @json res
