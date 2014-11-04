    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    supervisord = Promise.promisifyAll require 'supervisord'
    url = require 'url'
    {GatewayManager} = require 'tough-rate'

    run = (options) ->
      console.log "Configuring from #{options} ."
      users = null
      prov = null
      replicator = null
      supervisor = null

      replicate = (name,extensions) ->
        replicator.get "#{name} from master"
        .catch (error) ->
          console.error error
          console.error '(ignored)'
          {}
        .then (doc) ->
          source = url.parse options.prefix_source
          auth = (new Buffer source.auth).toString 'base64'
          doc._id ?= "#{name} from master"
          doc.source ?=
            url: url.format
              protocol: source.protocol
              host: source.host
              pathname: name
            headers:
              Authorization: "Basic #{auth}"
          doc.target ?= name
          doc.continuous ?= true
          extensions? doc
          delete doc._replication_state
          delete doc._replication_state_time
          delete doc._replication_id
          replicator.put doc

        .catch (error) ->
          console.error error
          if error.status? and error.status is 403
            console.log "Replication already started"
            return
          console.log "Replication from #{options.prefix_source}/#{name} failed."
          throw error

      Promise.resolve()

Generate the configuration for FreeSwitch
=========================================

      .then ->
        acls = ''
        for name, value of options.acls
          acls += """
            <list name="#{name}" default="deny">
          """
          for cidr in value
            acls += """
              <node type="allow" cidr="#{cidr}" />
            """
          acls += '</list>'

        fs.writeFileAsync 'conf/acl.conf.xml', acls, 'utf-8'

Configure CouchDB
=================

      .then ->
        users = new PouchDB "#{options.prefix_admin}/_users"
        prov = new PouchDB "#{options.prefix_admin}/provisioning"
        replicator = new PouchDB "#{options.prefix_admin}/_replicator"
        true
      .then ->
        prov.info()
      .catch (error) ->
        console.error error
        console.log "Unable to create local provisioning database"
        throw error
      .then ->
        users.get 'org.couchdb.user:tough-rate'
      .catch (error) ->
        console.error error
        console.error '(ignored)'
        {}
      .then (doc) ->
        doc._id ?= "org.couchdb.user:tough-rate"
        doc.name ?= 'tough-rate'
        doc.type ?= 'user'
        doc.password ?= 'tough-rate-password'
        doc.roles ?= ['provisioning_reader']
        users.put doc

      .catch (error) ->
        console.error error
        console.log "User creation failed."
        throw error

      .then ->
        prov.get GatewayManager.couch._id
      .catch (error) ->
        console.error error
        console.log '(ignored)'
        {}
      .then ({_rev}) ->
        doc = GatewayManager.couch
        doc._rev = _rev
        prov.put doc

      .catch (error) ->
        console.error error
        console.log "Inserting GatewayManager couchapp failed."
        throw error

      .then ->
        replicate 'provisioning', (doc) ->
          doc.filter ?= 'host/replication'
          doc.query_params ?=
            sip_domain_name: options.sip_domain_name

      .then ->
        source = new PouchDB "#{options.prefix_source}/provisioning"
        source.allDocs
          startkey: "ruleset:#{options.sip_domain_name}:"
          endkey: "ruleset:#{options.sip_domain_name};"
          include_docs: true

      .then ({rows}) ->
        console.log JSON.stringify rows
        it = Promise.resolve()
        for row in rows when row.doc?.database?
          do (row) ->
            it = it.then ->
              console.log "Going to replicate #{row.doc.database}"
              replicate row.doc.database

        it

      .then ->
        console.log "Configured."

      .then ->
        supervisor = Promise.promisifyAll supervisord.connect 'http://127.0.0.1:5700'
        supervisor.startProcessAsync 'tough-rate'
      .then ->
        console.log "Started tough-rate"

      .then ->
        supervisor.startProcessAsync 'freeswitch'
      .then ->
        console.log "Started FreeSwitch"


    if module is require.main
      fs.readFileAsync process.argv[2]
      .then (content) ->
        JSON.parse content
      .then (options) ->
        run options
      .catch (error) ->
        console.error error
        console.log "Configuration failed."
        process.exit 1
    else
      module.exports = run
