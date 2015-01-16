FROM shimaore/freeswitch

MAINTAINER Stéphane Alnet <stephane@shimaore.net>

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  git \
  make \
  supervisor
# Install Node.js using `n`.
RUN git clone https://github.com/tj/n.git
WORKDIR n
RUN make install
WORKDIR ..
RUN n 0.10.35
ENV NODE_ENV production

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
RUN npm install && npm cache clean

# Cleanup
USER root
RUN apt-get purge -y \
  build-essential \
  ca-certificates \
  curl \
  git \
  make
RUN apt-get autoremove -y
RUN apt-get clean

USER freeswitch
CMD ["supervisord", "-n"]

# 127.0.0.1:5700/tcp -- Supervisord
# 127.0.0.1:5702/tcp -- FreeSwitch event socket
# *:5701/tcp -- tough-rate event server
# *:5703/udp, *:5703/tcp -- SIP
# *:5704/tcp -- tough-rate web server
EXPOSE 5703/udp 5703/tcp 5704/tcp
