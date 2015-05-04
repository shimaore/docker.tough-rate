Standard `tough-rate`
---------------------

    cfg = require process.env.CONFIG

Default `use` list for tough-rate.

    cfg.use = [
      require './middleware/config'
      require './middleware/server'
      require 'tough-rate/middleware/setup'
      require 'tough-rate/middleware/numeric'
      require 'tough-rate/middleware/response-handlers'
      require 'tough-rate/middleware/local-number'
      require 'tough-rate/middleware/ruleset'
      require 'tough-rate/middleware/emergency'
      require 'tough-rate/middleware/routes-gwid'
      require 'tough-rate/middleware/routes-carrierid'
      require 'tough-rate/middleware/routes-registrant'
      require 'tough-rate/middleware/flatten'
      require 'tough-rate/middleware/cdr'
      require 'tough-rate/middleware/call-handler'
    ]

Default FreeSwitch configuration

    cfg.freeswitch = require './conf/freeswitch'

    ducks = require 'thinkable-ducks'
    ducks cfg
