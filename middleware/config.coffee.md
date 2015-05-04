    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    assert = require 'assert'
    url = require 'url'
    GatewayManager = require 'tough-rate/gateway_manager'
    {couch} = require 'tough-rate'
    pkg = require '../package.json'
    debug = (require 'debug') "#{pkg.name}:config"
    assert couch?, 'Missing design document'

    @name "#{pkg.name}/middleware/config"
    @config = (options) ->
      debug "Configuring #{pkg.name} version #{pkg.version}.", options
      users = null
      prov = null
      prov_master = null
      replicator = null

      replicate = (name,extensions) ->
        id = "Replicate #{name} from master"
        debug "Going to start replication of #{name}."
        Promise.resolve()
        .then ->
          target = new PouchDB "#{options.prefix_admin}/#{name}"
          target.info()
        .catch (error) ->
          debug error
          debug "Unable to create local #{name} database"
          throw error
        .then ->
          replicator.get id
        .catch (error) ->
          debug error
          debug '(ignored)'
          {}
        .then (doc) ->
          source = url.parse options.prefix_source
          auth = (new Buffer source.auth).toString 'base64'
          doc._id ?= id
          doc.source =
            url: url.format
              protocol: source.protocol
              host: source.host
              pathname: name
            headers:
              Authorization: "Basic #{auth}"
          doc.target = name
          doc.continuous = true
          extensions? doc
          delete doc._replication_state
          delete doc._replication_state_time
          delete doc._replication_id
          debug "Updating '#{id}'."
          replicator.put doc

        .catch (error) ->
          debug error
          if error.status? and error.status is 403
            debug "Replication already started"
            return
          debug "Replication from #{options.prefix_source}/#{name} failed."
          throw error

      Promise.resolve()

Configure CouchDB
=================

      .then ->
        users = new PouchDB "#{options.prefix_admin}/_users"
        prov = new PouchDB "#{options.prefix_admin}/provisioning"
        prov_master = new PouchDB options.prov_master_admin if options.prov_master_admin?
        replicator = new PouchDB "#{options.prefix_admin}/_replicator"
        true
      .then ->
        debug "Checking access to the local provisioning database."
        prov.info()
      .catch (error) ->
        debug error
        debug "Unable to create local provisioning database"
        throw error
      .then ->
        debug "Querying user 'tough-rate'."
        users.get 'org.couchdb.user:tough-rate'
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
        users.put doc

      .catch (error) ->
        debug error
        debug "User creation failed."
        throw error

      .then ->
        debug "Updating GatewayManager design document to version #{couch.version}."
        prov.get GatewayManager.couch._id
      .catch (error) ->
        debug error
        debug '(ignored)'
        {}
      .then ({_rev}) ->
        doc = GatewayManager.couch
        doc._rev = _rev if _rev?
        prov.put doc
      .catch (error) ->
        debug error
        debug "Inserting GatewayManager couchapp failed."
        throw error

      .then ->
        if prov_master?
          debug "Updating Master design document to version #{couch.version}."
          prov_master.get couch._id
        else
          {}
      .catch (error) ->
        debug error
        debug '(ignored)'
        {}
      .then ({_rev}) ->
        if prov_master?
          doc = couch
          doc._rev = _rev if _rev?
          prov_master?.put doc
      .catch (error) ->
        debug error
        debug "Inserting Master couchapp failed."
        throw error

      .then ->
        replicate 'provisioning', (doc) ->
          doc.filter = 'tough-rate-source/replication'
          doc.query_params =
            sip_domain_name: options.sip_domain_name

      .then ->

        source = new PouchDB "#{options.prefix_source}/provisioning"
        debug "Querying for rulesets on master database."
        source.allDocs
          startkey: "ruleset:#{options.sip_domain_name}:"
          endkey: "ruleset:#{options.sip_domain_name};"
          include_docs: true

      .then ({rows}) ->
        debug JSON.stringify rows
        it = Promise.resolve()
        for row in rows when row.doc?.database?
          do (row) ->
            it = it.then ->
              debug "Going to replicate #{row.doc.database}"
              replicate row.doc.database

        it

      .then ->
        debug "Configured."
