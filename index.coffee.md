Standard `tough-rate`
---------------------

    pkg = require './package.json'
    debug = (require 'debug') "#{pkg.name}:index"

    debug "Loading #{process.env.CONFIG}"
    cfg = require process.env.CONFIG

Default `use` list for tough-rate.

    debug 'cfg.use'
    cfg.use = [
      'huge-play/middleware/setup'
      './middleware/config'
      './middleware/server'
      'tough-rate/middleware/setup'
      'tough-rate/middleware/numeric'
      'tough-rate/middleware/response-handlers'
      'tough-rate/middleware/local-number'
      'tough-rate/middleware/ruleset'
      'tough-rate/middleware/emergency'
      'tough-rate/middleware/routes-gwid'
      'tough-rate/middleware/routes-carrierid'
      'tough-rate/middleware/routes-registrant'
      'tough-rate/middleware/flatten'
      'tough-rate/middleware/cdr'
      'tough-rate/middleware/call-handler'
    ]

    cfg.use = cfg.use.map (m) ->
      debug "Requiring #{m}"
      require m

Default FreeSwitch configuration

    debug 'Loading conf/freeswitch'
    cfg.freeswitch = require 'tough-rate/conf/freeswitch'

    debug 'Loading thinkable-ducks'
    ducks = require 'thinkable-ducks'
    debug 'Starting'
    ducks cfg
    debug 'Ready'
