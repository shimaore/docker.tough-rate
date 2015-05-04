docker.tough-rate
=================

This new version of (docker.)tough-rate uses:
- useful-wind, the generic FreeSwitch middleware router and call-server, based on the `esl` FreeSwitch socket API for Node.js;
- thinkable-ducks, the generic FreeSwitch image that supports useful-wind;
- tough-rate, the Node.js LCR engine (which now uses `useful-wind`);
- and the present code (`middelware/*` and a `Dockerfile`), which provides CCNQ4 database adaptation and then hands it off to thinkable-ducks.
