nodeOsc = require 'node-osc'

usedPorts = {}

exports.Client = (port, host = '127.0.0.1')->
  new nodeOsc.Client host, port


# Gaurantee the creation of a server (or throw an error)
#
# Note that the port argument is the first port that we attempt
# to open. If that fails, we will keep trying on other ports.
#
# Note that we will never try the same port twice, even if we
# call Server with the same port twice. Ports that have already
# been attempted are cached in the usedPort object.
exports.Server = (port = 8000, callback, host = '127.0.0.1')->
  server        = null
  attemptCount  = 0
  maxAttempts   = 10

  findOpenServer = (check)->
    attemptCount += 1

    if usedPorts[check]
      return findOpenServer[check + 1]

    usedPorts[check] = true
    rand = 'test:' + Math.random()

    # If we create the server, but do not receive the test
    # message, we must have this port must not be available.
    timeout2 = null
    timeout1 = setTimeout ->
      timeout2 = setTimeout ->
        # we didn't get an answer - this port is not available
        if attemptCount > maxAttempts
          return callback(new Error 'Failed to find available port')
        else
          findOpenServer check + 1 # recurse
      , 8
    , 8

    # It seems that attempting to create a server on a used port
    # throws an error on some platforms, but not others.
    try
      server = new nodeOsc.Server(check, host)
      server.on 'message', (msg, rinfo)->
        if msg[1] == rand
          # we received the message. the port is available
          if timeout2 then clearTimeout timeout2 # don't recurse
          if timeout1 then clearTimeout timeout1
          callback null, server
      client = new nodeOsc.Client host, check
      client.send '/random/test', rand

  findOpenServer port
