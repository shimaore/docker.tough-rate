    {expect} = require 'chai'

    it 'The FreeSwitch configuration should accept phrases', ->
      options = require '../local/example.json'
      opts = {}
      for own k,v of options
        opts[k] = v
      opts.phrases = [
        require 'bumpy-lawyer/fr'
      ]
      config = (require '../conf/freeswitch') opts
      expect(config.match /<action function="play" data="voicemail\/vm-record_greeting.wav"\/>/)

    it 'The FreeSwitch configuration', ->
      options = require '../local/example.json'
      config = (require '../conf/freeswitch') options

      expected_config = '''
        <?xml version="1.0" encoding="utf-8" ?>
        <document type="freeswitch/xml">
          <section name="configuration">
            <configuration name="switch.conf">
              <settings>
                <param name="switchname" value="freeswitch-server"/>
                <param name="core-db-name" value="/dev/shm/freeswitch/core-server.db"/>
                <param name="rtp-start-port" value="49152"/>
                <param name="rtp-end-port" value="65534"/>
                <param name="max-sessions" value="2000"/>
                <param name="sessions-per-second" value="2000"/>
                <param name="min-idle-cpu" value="1"/>
                <param name="loglevel" value="err"/>
              </settings>
            </configuration>
            <configuration name="modules.conf">
              <modules>
                <load module="mod_logfile"/>
                <load module="mod_event_socket"/>
                <load module="mod_commands"/>
                <load module="mod_dptools"/>
                <load module="mod_loopback"/>
                <load module="mod_dialplan_xml"/>
                <load module="mod_sofia"/>
              </modules>
            </configuration>
            <configuration name="logfile.conf">
              <settings>
                <param name="rotate-on-hup" value="true"/>
              </settings>
              <profiles>
                <profile name="default">
                  <settings>
                    <param name="logfile" value="log/freeswitch.log"/>
                    <param name="rollover" value="10000000"/>
                    <param name="uuid" value="true"/>
                  </settings>
                  <mappings>
                    <map name="important" value="err,crit,alert"/>
                  </mappings>
                </profile>
              </profiles>
            </configuration>
            <configuration name="event_socket.conf">
              <settings>
                <param name="nat-map" value="false"/>
                <param name="listen-ip" value="127.0.0.1"/>
                <param name="listen-port" value="5702"/>
                <param name="password" value="ClueCon"/>
              </settings>
            </configuration>
            <configuration name="acl.conf">
              <network-lists>
                <list name="default" default="deny">
                  <node type="allow" cidr="172.17.42.0/8"/>
                  <node type="allow" cidr="127.0.0.0/8"/>
                </list>
              </network-lists>
            </configuration>
            <configuration name="sofia.conf">
              <global_settings>
                <param name="log-level" value="1"/>
                <param name="debug-presence" value="0"/>
              </global_settings>
              <profiles>
                <profile name="tough-rate-sender">
                  <settings>
                    <param name="user-agent-string" value="tough-rate-sender-5060"/>
                    <param name="username" value="tough-rate-sender"/>
                    <param name="debug" value="2"/>
                    <param name="sip-trace" value="false"/>
                    <param name="sip-port" value="5060"/>
                    <param name="bind-params" value="transport=udp,tcp"/>
                    <param name="sip-ip" value="0.0.0.0"/>
                    <param name="ext-sip-ip" value="auto"/>
                    <param name="rtp-ip" value="0.0.0.0"/>
                    <param name="ext-rtp-ip" value="auto"/>
                    <param name="apply-inbound-acl" value="default"/>
                    <param name="dialplan" value="XML"/>
                    <param name="context" value="context-sender"/>
                    <param name="auth-calls" value="false"/>
                    <param name="auth-all-packets" value="false"/>
                    <param name="accept-blind-reg" value="true"/>
                    <param name="accept-blind-auth" value="true"/>
                    <param name="sip-options-respond-503-on-busy" value="false"/>
                    <param name="pass-callee-id" value="false"/>
                    <param name="caller-id-type" value="pid"/>
                    <param name="manage-presence" value="false"/>
                    <param name="manage-shared-appearance" value="false"/>
                    <param name="enable-soa" value="true"/>
                    <param name="inbound-codec-negotiation" value="scrooge"/>
                    <param name="inbound-late-negotiation" value="true"/>
                    <param name="inbound-codec-prefs" value="PCMA,PCMU"/>
                    <param name="outbound-codec-prefs" value="PCMA,PCMU"/>
                    <param name="renegotiate-codec-on-reinvite" value="true"/>
                    <param name="inbound-bypass-media" value="true"/>
                    <param name="inbound-proxy-media" value="false"/>
                    <param name="media-option" value="bypass-media-after-att-xfer"/>
                    <param name="inbound-zrtp-passthru" value="false"/>
                    <param name="disable-transcoding" value="true"/>
                    <param name="inbound-use-callid-as-uuid" value="true"/>
                    <param name="dtmf-type" value="rfc2833"/>
                    <param name="dtmf-duration" value="200"/>
                    <param name="rfc2833-pt" value="101"/>
                    <param name="use-rtp-timer" value="true"/>
                    <param name="rtp-timer-name" value="soft"/>
                    <param name="pass-rfc2833" value="true"/>
                    <param name="max-proceeding" value="2000"/>
                    <param name="nonce-ttl" value="60"/>
                    <param name="NDLB-received-in-nat-reg-contact" value="false"/>
                    <param name="nat-options-ping" value="false"/>
                    <param name="all-reg-options-ping" value="false"/>
                    <param name="aggressive-nat-detection" value="false"/>
                    <param name="rtp-timeout-sec" value="300"/>
                    <param name="rtp-hold-timeout-sec" value="1800"/>
                    <param name="disable-transfer" value="true"/>
                    <param name="disable-register" value="true"/>
                    <param name="enable-3pcc" value="false"/>
                    <param name="stun-enabled" value="false"/>
                    <param name="stun-auto-disable" value="true"/>
                    <param name="timer-T1" value="250"/>
                    <param name="timer-T1X64" value="16000"/>
                    <param name="timer-T2" value="4000"/>
                    <param name="timer-T4" value="5000"/>
                  </settings>
                </profile>
              </profiles>
            </configuration>
            <configuration name="httapi.conf">
              <settings>
              </settings>
              <profiles>
                <profile name="default">
                  <params>
                    <param name="gateway-url" value=""/>
                    <param name="gateway-credentials" value=""/>
                    <param name="auth-scheme" value="basic"/>
                    <param name="enable-cacert-check" value="true"/>
                    <param name="enable-ssl-verifyhost" value="true"/>
                    <param name="timeout" value="120"/>
                  </params>
                </profile>
              </profiles>
            </configuration>
          </section>
          <section name="dialplan">
            <context name="context-sender">
              <extension name="socket">
                <condition field="destination_number" expression="^.+$">
                  <action application="socket" data="127.0.0.1:5701 async full"/>
                </condition>
              </extension>
            </context>
          </section>
        </document>

      '''.replace /\n */g, '\n'

      expect(config).to.equal expected_config
