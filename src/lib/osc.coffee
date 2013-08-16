nodeOsc = require 'node-osc'

Client = (port, host = 'localhost')->
  new nodeOsc.Client host, port

module.exports.Client = Client
