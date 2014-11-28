{renderable} = require 'acoustic-line'

module.exports = renderable (o) ->
  {doctype,document,section,configuration,settings,param,modules,module,load,network_lists,list,node,global_settings,profiles,profile,context,extension,condition,action} = require 'acoustic-line'
  name = o.name ? 'server'
  the_profiles = o.profiles ?
    sender:
      sip_port: 5060
      socket_port: 5701

  doctype()
  document type:'freeswitch/xml', ->
    section name:'configuration', ->
      configuration name:'switch.conf', ->
        settings ->
          param name:'switchname', value:"freeswitch-#{name}"
          param name:'core-db-name', value:"/dev/shm/freeswitch/core-#{name}.db"
          param name:'rtp-start-port', value:49152
          param name:'rtp-end-port', value:65534
          param name:'max-sessions', value:2000
          param name:'sessions-per-second', value:2000
          param name:'min-idle-cpu', value:1
          param name:'loglevel', value:'debug'
      configuration name:'modules.conf', ->
        modules ->
          modules_to_load = [
            'mod_event_socket'
            'mod_commands'
            'mod_dptools'
            'mod_loopback'
            'mod_dialplan_xml'
            'mod_sofia'
          ]
          for module in modules_to_load
            load {module}
      configuration name:'event_socket.conf', ->
        settings ->
          param name:'nat-map', value:false
          param name:'listen-ip', value:'127.0.0.1'
          socket_port = o.socket_port ? 5702
          param name:'listen-port', value: socket_port
          param name:'password', value:'ClueCon'
      configuration name:"acl.conf", ->
        network_lists ->
          for name, cidrs of o.acls
            list name:name, default:'deny', ->
              for cidr in cidrs
                node type:'allow', cidr:cidr

      configuration name:'sofia.conf', ->
        global_settings ->
          param name:'log-level', value:1
          param name:'debug-presence', value:0
        profiles ->
          for name, profile of the_profiles
            profile.timer_t1 ?= 250
            profile.timer_t4 ?= 4000
            profile.timer_t2 ?= 2000
            profile.timer_t1x64 ?= profile.timer_t2
            profile.local_ip = 'auto'
            profile.name = name
            profile.context ?= "context-#{name}"
            (require './profile-tough-rate') profile

    section name:'dialplan', ->

      for name, profile of the_profiles
        context name:"context-#{name}", ->
          extension name="socket", ->
            condition field:'destination_number', expression:'^.+$', ->
              action application:'socket', data:"127.0.0.1:#{profile.socket_port} async full"
