FROM shimaore/freeswitch

MAINTAINER Stéphane Alnet <stephane@shimaore.net>

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs-legacy npm \
    supervisor
RUN apt-get autoremove -y
RUN apt-get clean

# FreeSwitch configuration
COPY conf/ /usr/local/freeswitch/conf

# tough-rate installation
RUN useradd -m tough-rate
USER tough-rate
WORKDIR /home/tough-rate
COPY . /home/tough-rate
RUN npm install

CMD ["supervisord", "-n"]

# 127.0.0.1:5700/tcp -- Supervisord
# 127.0.0.1:5702/tcp -- FreeSwitch event socket
# *:5701/tcp -- tough-rate event server
# *:5703/udp, *:5703/tcp -- SIP
EXPOSE 5703/udp 5703/tcp
