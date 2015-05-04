FROM shimaore/thinkable-ducks:1.1.2

MAINTAINER Stéphane Alnet <stephane@shimaore.net>

COPY . /opt/thinkable-ducks
RUN npm install
