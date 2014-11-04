    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    {GatewayManager,CallServer,Router} = require 'tough-rate'
    statistics = require 'winston'
    assert = require 'assert'

    run = (options) ->
      provisioning = null
      assert options.provisioning?, 'Missing `provisioning` option.'
      assert options.sip_domain_name?, 'Missing `sip_domain_name` option.'

      Promise.resolve()
      .then ->
        provisioning = new PouchDB options.provisioning
        options.provisioning = provisioning
        options.ruleset_of = (x) ->
          provisioning.get "ruleset:#{options.sip_domain_name}:#{x}"
          .then (doc) ->
            assert doc.database?, "Ruleset #{options.sip_domain_name}:#{x} should have a database field."
            data =
              ruleset: doc
              database: new PouchDB doc.database

We _must_ return an object. The router will detect no data is present and report via SIP.

          .catch (error) ->
            statistics.error error
            statistics.log "Could not locate information for ruleset #{x}."
            {}

        options.statistics = statistics
        options.respond ?= true

        options.gateway_manager = new GatewayManager provisioning, options.sip_domain_name, {statistics}
        options.gateway_manager.init()

      .catch (error) ->
        console.error error
        console.log "Gateway Manager init failed"
        throw error

      .then ->

        options.router = new Router options
        options.router.plugin require 'tough-rate/plugin-registrant'

      .then ->
        new CallServer options.port, options

    if module is require.main
      fs.readFileAsync process.argv[2]
      .then (content) ->
        JSON.parse content
      .then (options) ->
        run options
      .catch (error) ->
        statistics.error error
        statistics.log "Server failed."
        throw error
    else
      module.exports = run
