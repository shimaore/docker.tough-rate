Web Services
============

    Zappa = require 'zappajs'
    supervisord = require 'supervisord'
    pkg = require './package.json'
    Promise = require 'bluebird'

    module.exports = (options,server) ->

      sup = ->
        Promise.promisifyAll supervisord.connect 'http://127.0.0.1:5700'

      web = Zappa.run options.web, ->

CallServer statistics
---------------------

        @get '/statistics/:key', ->
          @res.type 'json'
          value = server.statistics.get @params.key
          if value?
            @send value.toJSON()
          else
            @res.status(500).json error:'No such key', key:@params.key

Generic statistics
------------------

        @get '/', ->
          @json
            ok:true
            package: pkg.name
            version: pkg.version
            uptime: process.uptime()
            memory: process.memoryUsage()

Supervisor info
---------------

        @get '/supervisor', ->
          supervisor = sup()
          res = {}
          supervisor.getSupervisorVersionAsync()
          .then (version) ->
            res.version = version
            supervisor.getStateAsync()
          .then (state) ->
            res.state = state
            supervisor.getAllProcessInfoAsync()
          .then (processes) ->
            res.processes = processes
          .then =>
            @json res
          .catch (error) =>
            @res.status(500).json error:error.toString()
