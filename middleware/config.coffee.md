    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    assert = require 'assert'
    nimble = require 'nimble-direction'
    GatewayManager = require 'tough-rate/gateway_manager'
    {couch} = require 'tough-rate'
    pkg = require '../package.json'
    debug = (require 'debug') "#{pkg.name}:config"
    assert couch?, 'Missing design document'

    @name = "#{pkg.name}/middleware/config"
    @config = ->
      cfg = @cfg
      debug "Configuring #{pkg.name} version #{pkg.version}.", cfg
      assert cfg.prefix_source?, 'Missing prefix_source'
      assert cfg.sip_domain_name?, 'Missing sip_domain_name'

Configure CouchDB
=================

      nimble cfg

Create a local `tough-rate` user
--------------------------------

      .then ->
        debug "Querying user 'tough-rate'."
        cfg.users.get 'org.couchdb.user:tough-rate'
      .catch (error) ->
        debug error
        debug '(ignored)'
        {}
      .then (doc) ->
        debug "Updating user 'tough-rate'."
        doc._id ?= "org.couchdb.user:tough-rate"
        doc.name ?= 'tough-rate'
        doc.type ?= 'user'
        doc.password = 'tough-rate-password'
        doc.roles = ['provisioning_reader']
        cfg.users.put doc

      .catch (error) ->
        debug error
        debug "User creation failed."
        throw error

Push the GatewayManager design document to the local provisioning database
--------------------------------------------------------------------------

      .then ->
        debug "Updating GatewayManager design document to version #{couch.version}."
        cfg.push GatewayManager.couch
      .catch (error) ->
        debug "Inserting GatewayManager couchapp failed."
        throw error

Push the `tough-rate` design document to the master provisioning database
-------------------------------------------------------------------------

      .then ->
        cfg.master_push couch
      .catch (error) ->
        debug "Inserting Master couchapp failed."
        throw error

      .then ->
        cfg.replicate 'provisioning', (doc) ->
          debug "Using replication filter #{couch.replication_filter}"
          doc.filter = couch.replication_filter
          doc.query_params =
            sip_domain_name: cfg.sip_domain_name

      .then ->

        source = new PouchDB "#{cfg.prefix_source}/provisioning"
        debug "Querying for rulesets on master database."
        source.allDocs
          startkey: "ruleset:#{cfg.sip_domain_name}:"
          endkey: "ruleset:#{cfg.sip_domain_name};"
          include_docs: true

      .then ({rows}) ->
        debug JSON.stringify rows
        replications = for row in rows when row.doc?.database?
          do (row) ->
            debug "Going to replicate #{row.doc.database}"
            cfg.replicate row.doc.database
        Promise.all replications

      .then ->
        debug "Configured."
