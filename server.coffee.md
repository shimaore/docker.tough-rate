    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    {CallServer} = require 'tough-rate'
    logger = require 'winston'
    assert = require 'assert'
    pkg = require './package.json'

    run = (options) ->
      provisioning = null
      assert options.provisioning?, 'Missing `provisioning` option.'
      assert options.sip_domain_name?, 'Missing `sip_domain_name` option.'
      assert options.prefix_local?, 'Missing `prefix_local` option.'
      assert options.profile? , 'Missing `profile` option.'

      logger.info "Booting #{pkg.name} #{pkg.version}.", options
      Promise.resolve()
      .then ->
        provisioning = new PouchDB options.provisioning
        options.provisioning = provisioning

`ruleset_of`
------------

Retrieve the ruleset (and ruleset database) for the given ruleset name.

        options.ruleset_of = (x) ->
          provisioning.get "ruleset:#{options.sip_domain_name}:#{x}"
          .then (doc) ->
            assert doc.database?, "Ruleset #{options.sip_domain_name}:#{x} should have a database field."
            data =
              ruleset: doc
              ruleset_database: new PouchDB "#{options.prefix_local}/#{doc.database}"

We _must_ return an object, even if an error occurred. The router will detect no data is present and report the problem via SIP.

          .catch (error) ->
            logger.error "Could not locate information for ruleset #{x} in #{options.sip_domain_name}.", error.toString()
            {}

        options.logger = logger

The promise resolution is needed here to allow `new PouchDB` to complete.

      .then ->
        server = new CallServer options.port, options
        if options.default?
          server.gateway_manager.set options.default

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
