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
RUN useradd -m tough-rate
COPY . /home/tough-rate
RUN chown -R tough-rate.tough-rate /home/tough-rate
USER tough-rate
WORKDIR /home/tough-rate
RUN npm install
RUN mkdir -p log

# Cleanup
RUN npm cache clean
USER root
RUN apt-get purge -y \
    npm build-essential
RUN apt-get autoremove -y
RUN apt-get clean

USER tough-rate
CMD ["supervisord", "-n"]

# 127.0.0.1:5700/tcp -- Supervisord
# 127.0.0.1:5702/tcp -- FreeSwitch event socket
# *:5701/tcp -- tough-rate event server
# *:5703/udp, *:5703/tcp -- SIP
EXPOSE 5703/udp 5703/tcp
