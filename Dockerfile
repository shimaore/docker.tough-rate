FROM shimaore/thinkable-ducks:4.3.3

MAINTAINER Stéphane Alnet <stephane@shimaore.net>

COPY . /opt/thinkable-ducks
RUN npm install
