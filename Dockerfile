FROM shimaore/thinkable-ducks:4.2.1

MAINTAINER Stéphane Alnet <stephane@shimaore.net>

COPY . /opt/thinkable-ducks
RUN npm install
