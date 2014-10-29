    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    supervisord = Promise.promisifyAll require 'supervisord'
    url = require 'url'
    {GatewayManager} = require 'tough-rate'

    run = (filename) ->
      console.log "Configuring from #{filename} ."
      options = null
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
      .then ->

Configure CouchDB
=================

        users = new PouchDB "#{options.prefix_admin}/_users"
        users.put
          _id:"org.couchdb.user:tough-rate"
          name:'tough-rate'
          password:'tough-rate-password'
          roles:['provisioning_reader']

      .catch (error) ->
        console.log "User creation failed."
        throw error

      .then ->

        prov = new PouchDB "#{options.prefix_admin}/provisioning"
        prov.put GatewayManager.couch

      .catch (error) ->
        console.log "Inserting GatewayManager couchapp failed."
        throw error

      .then ->

        replicator = new PouchDB "#{options.prefix_admin}/_replicator"
        replicator.delete 'provisioning from master'
      .catch -> true
      .then ->
        replicator = new PouchDB "#{options.prefix_admin}/_replicator"
        source = url.parse options.source_provisioning
        replicator.put
          _id:'provisioning from master'
          source:
            url: "#{url.protocol}//#{url.host}#{url.path}"
            headers:
              Authorization: "Basic #{(new Buffer url.auth).toString 'base64'}"
          target:
            'provisioning'
          continuous: true

      .catch (error) ->
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
        console.log "Configuration failed."
        process.exit 1
    else
      module.exports = run
