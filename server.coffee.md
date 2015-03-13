    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    {CallServer} = require 'tough-rate'
    winston = require 'winston'
    assert = require 'assert'
    pkg = require './package.json'

    logger = new winston.Logger
      transports: [
        new winston.transports.File
          level: 'info'
          filename: "log/#{pkg.name}-server.log"
          maxsize: 1000*1000
          maxFiles: 50
      ]

    run = (options) ->
      provisioning = null
      assert options.provisioning?, 'Missing `provisioning` option.'
      assert options.sip_domain_name?, 'Missing `sip_domain_name` option.'
      assert options.profile? , 'Missing `profile` option.'

      logger.info "Booting #{pkg.name} #{pkg.version}.", options
      Promise.resolve()
      .then ->
        provisioning = new PouchDB options.provisioning
        options.provisioning = provisioning

`ruleset_of`
------------

Retrieve the ruleset (and ruleset database) for the given ruleset name.

        if options.prefix_local?
          options.ruleset_of = (x) ->
            provisioning.get "ruleset:#{options.sip_domain_name}:#{x}"
            .then (doc) ->
              assert doc.database?, "Ruleset #{options.sip_domain_name}:#{x} should have a database field."
              data =
                ruleset: doc
                ruleset_database: new PouchDB "#{options.prefix_local}/#{doc.database}"

We _must_ return an object, even if an error occurred. The router will detect no data is present and report the problem via SIP.

            .catch (error) ->
              logger.error "#{pkg.name} #{pkg.version}: Could not locate information for ruleset #{x} in #{options.sip_domain_name}.", error.toString()
              {}

        else
          logger.info "#{pkg.name} #{pkg.version}: no `prefix_local` was present in the configuration, hopefully you won't use rulesets."
          options.ruleset_of = ->
            logger.error "#{pkg.name} #{pkg.version}: `ruleset_of` was called but no `prefix_local` was present in the configuration."
            {}

        options.logger = logger

The promise resolution is needed here to allow `new PouchDB` to complete.

      .then ->
        server = new CallServer options.port, options
        if options.default?
          server.gateway_manager.set options.default

        (require './web') options, server
        (require './notify') options, server
      .catch (error) ->
        logger.error "Terminating #{pkg.name} server: #{error}"
        throw error

Toolbox
-------

This may work as an app or a module.

    if module is require.main
      fs.readFileAsync process.argv[2]
      .then (content) ->
        JSON.parse content
      .then (options) ->
        run options
      .catch (error) ->
        logger.error "Server failed.", error.toString()
        throw error
    else
      module.exports = run
