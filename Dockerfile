FROM shimaore/freeswitch

MAINTAINER Stéphane Alnet <stephane@shimaore.net>

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs-legacy \
    supervisor
RUN apt-get install -y --no-install-recommends \
    npm build-essential

# FreeSwitch configuration
COPY conf/ /usr/local/freeswitch/conf

# tough-rate installation
RUN mkdir -p /opt/tough-rate
COPY . /opt/tough-rate
RUN chown -R freeswitch.freeswitch /opt/tough-rate
USER freeswitch
WORKDIR /opt/tough-rate
RUN mkdir -p \
  log \
  local
RUN npm install

# Cleanup
RUN npm cache clean
USER root
RUN apt-get purge -y \
    npm build-essential
RUN apt-get autoremove -y
RUN apt-get clean

USER freeswitch
CMD ["supervisord", "-n"]

# 127.0.0.1:5700/tcp -- Supervisord
# 127.0.0.1:5702/tcp -- FreeSwitch event socket
# *:5701/tcp -- tough-rate event server
# *:5703/udp, *:5703/tcp -- SIP
EXPOSE 5703/udp 5703/tcp
