Map `statistics` (that is, CaringBand-as-EventEmitter) messages to Socket.io messages.

    module.exports = (options,server) ->
      return unless options.notify?

      socket = io options.notify
      server.statistics.on 'add', (data) ->
        socket.emit 'statistics:add',
          host: options.host
          data: data.toJSON()
      server.statistics.on 'call', (data) ->
        socket.emit 'call',
          host: options.host
          data: data
      server.statistics.on 'report', (data) ->
        socket.emit 'report',
          host: options.host
          data: data

    io = require 'socket.io-client'
    pkg = require './package.json'
