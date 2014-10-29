    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    {GatewayManager,CallServer} = require 'tough-rate'

    options = null
    provisioning = null

    fs.readFileAsync process.argv[2]
    .then (content) ->
      options = JSON.parse content
      provisioning = new PouchDB options.provisioning
      options.provisioning = provisioning
      options.ruleset_of = (x) ->
        provisioning.get "ruleset:#{sip_domain_name}:#{x}"
        .then (doc) ->
          ruleset: doc
          database: new PouchDB doc.database
      options.statistics = require 'winston'

      options.gateway_manager = new GatewayManager provisioning, options.sip_domain_name
      options.gateway_manager.init()

    .catch (error) ->
      console.log "Gateway Manager init failed"
      throw error

    .then ->

      options.router = new Router options
      options.router.plugin require 'tough-rate/plugin-registrant'

    .then ->
      new CallServer options.port, options