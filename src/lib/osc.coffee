nodeOsc = require 'node-osc'

exports.Client = (port, host = 'localhost')->
  new nodeOsc.Client host, port

exports.Server = (callback, port = 8000, host = '0.0.0.0')->
  server = null

  findOpenServer = (check, max)->
    max = max or check + 10
    rand = 'test:' + Math.random()

    checkAnother = setTimeout ->
      # we didn't get an answer - this port is not available
      ''
    , 10

    server = new nodeOsc.Server(check, host)
    server.on 'message', (msg, rinfo)->
      if msg[1] == rand
        # we received the message. the port is available
        clearTimeout checkAnother
        callback null, server
    client = new nodeOsc.Client host, check
    client.send '/random/test', rand

  findOpenServer port
