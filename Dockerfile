FROM shimaore/thinkable-ducks:4.2.0

MAINTAINER Stéphane Alnet <stephane@shimaore.net>

COPY . /opt/thinkable-ducks
RUN npm install
