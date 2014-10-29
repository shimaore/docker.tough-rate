    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    supervisord = Promise.promisifyAll require 'supervisord'
    url = require 'url'
    {GatewayManager} = require 'tough-rate'

    run = (filename) ->
      console.log "Configuring from #{filename} ."
      options = null
      users = null
      prov = null
      replicator = null

      fs.readFileAsync filename
      .then (content) ->
        options = JSON.parse content

Generate the configuration for FreeSwitch
=========================================

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
        users.get 'org.couchdb.user:tough-rate'
      .catch ->
        {}
      .then (doc) ->
        doc._id ?= "org.couchdb.user:tough-rate"
        doc.name ?= 'tough-rate'
        doc.password ?= 'tough-rate-password'
        doc.roles ?= ['provisioning_reader']
        users.put doc

      .catch (error) ->
        console.error error
        console.log "User creation failed."
        throw error

      .then ->
        prov.put GatewayManager.couch

      .catch (error) ->
        console.error error
        console.log "Inserting GatewayManager couchapp failed."
        # Do not throw since we don't handle _rev -- FIXME

      .then ->
        replicator.get 'provisioning from master'
      .catch -> {}
      .then (doc) ->
        source = url.parse options.source_provisioning
        auth = (new Buffer source.auth).toString 'base64'
        doc._id ?= 'provisioning from master'
        doc.source ?=
          url: "#{source.protocol}//#{source.host}#{source.path}"
          headers:
            Authorization: "Basic #{auth}"
        doc.target ?= 'provisioning'
        doc.continuous ?= true
        replicator.put doc

      .catch (error) ->
        console.error error
        console.log "Replication from #{options.source_provisioning} failed."
        throw error

      .then ->
        console.log "Configured."

      .then ->
        client = supervisord.connect 'http://127.0.0.1:5700'
        client.startProcess 'tough-rate'
      .then ->
        console.log "Started tough-rate"

      .then ->
        client = supervisord.connect 'http://127.0.0.1:5700'
        client.startProcess 'freeswitch'
      .then ->
        console.log "Started FreeSwitch"


    if module is require.main
      run process.argv[2]
      .catch (error) ->
        console.error error
        console.log "Configuration failed."
        process.exit 1
    else
      module.exports = run
