    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    {CallServer} = require 'tough-rate'
    assert = require 'assert'
    pkg = require '../package.json'
    debug = (require 'debug') "#{pkg.name}:server"

    @name = "#{pkg.name}/middleware/server"
    @web = ->
      @cfg.versions[pkg.name] = pkg.version

    @server_pre = ->
      options = @cfg
      provisioning = null
      assert options.provisioning?, 'Missing `provisioning` option.'
      assert options.sip_domain_name?, 'Missing `sip_domain_name` option.'
      assert options.profile? , 'Missing `profile` option.'

      debug "Booting #{pkg.name} #{pkg.version}.", options
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
            debug "#{pkg.name} #{pkg.version}: Could not locate information for ruleset #{x} in #{options.sip_domain_name}.", error.toString()
            {}

      else
        debug "#{pkg.name} #{pkg.version}: no `prefix_local` was present in the configuration, hopefully you won't use rulesets."
        options.ruleset_of = ->
          debug "#{pkg.name} #{pkg.version}: `ruleset_of` was called but no `prefix_local` was present in the configuration."
          {}
