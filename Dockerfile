FROM shimaore/freeswitch

MAINTAINER Stéphane Alnet <stephane@shimaore.net>

USER root
# These will remain inside the archive.
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs-legacy \
    supervisor
# Build tools, will get removed at the end.
RUN apt-get install -y --no-install-recommends \
    build-essential \
    npm

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
RUN apt-get clean
# RUN apt-get autoclean
# RUN apt-get purge -y \
#     build-essential \
#     npm
# RUN apt-get autoremove -y
RUN ls -l /bin/sh

USER freeswitch
CMD ["supervisord", "-n"]

# 127.0.0.1:5700/tcp -- Supervisord
# 127.0.0.1:5702/tcp -- FreeSwitch event socket
# *:5701/tcp -- tough-rate event server
# *:5703/udp, *:5703/tcp -- SIP
EXPOSE 5703/udp 5703/tcp
