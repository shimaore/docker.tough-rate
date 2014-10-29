    PouchDB = require 'pouchdb'
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
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

        prov = new PouchDB "#{options.prefix_admin}/provisioning"
        prov.replicate.from options.source_provisioning

      .catch (error) ->
        console.log "Starting replication failed."
        throw error

      .then ->
        console.log "Configured."

    if module is require.main
      run process.argv[2]
      .catch (error) ->
        console.log "Configuration failed."
        throw error
    else
      module.exports = run
