Generate the configuration
==========================

    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'

    run = (filename) ->
      fs.readFileAsync filename
      .then (content) ->
        options = JSON.parse content
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
        console.log "Configured."

    if module is require.main
      run process.argv[2]
    else
      module.exports = run
