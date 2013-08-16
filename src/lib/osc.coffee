nodeOsc = require 'node-osc'

exports.Client = (port, host = 'localhost')->
  new nodeOsc.Client host, port

exports.Server = (port = 8000, callback, host = '0.0.0.0')->
  server = null
  max = port + 9

  findOpenServer = (check)->
    rand = 'test:' + Math.random()

    checkAnother = setTimeout ->
      # we didn't get an answer - this port is not available
      if check > max
        return callback(new Error 'Failed to find available port')
      else
        findOpenServer check + 1 # recurse
    , 10

    server = new nodeOsc.Server(check, host)
    server.on 'message', (msg, rinfo)->
      if msg[1] == rand
        # we received the message. the port is available
        clearTimeout checkAnother # don't recurse
        callback null, server
    client = new nodeOsc.Client host, check
    client.send '/random/test', rand

  findOpenServer port
