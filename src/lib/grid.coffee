events  = require 'events'
osc     = require './osc'
nodeOsc = require 'node-osc'

module.exports = makeGrid = (devicePort)->
  grid        = new events.EventEmitter()  # object to be returned
  client      = new nodeOsc.Client('localhost', devicePort)
  server      = null # create this once we have a port
  prefix      = null
  setLedAddr  = null
  keyAddr     = null
  width       = undefined
  height      = undefined
  port        = null

  new osc.Server 10200, (error, _server)->
    if error
      console.log 'Error creating grid server:', error
      throw error
    server = _server
    port = server.port
    server.on 'message', (msg, info)->
      address = msg[0]
      if address == '/sys/prefix'
        handlePrefix(msg)
      if address == '/sys/size'
        handleSize(msg)
      else if address == keyAddr
        handleKey(msg)

    # Set default port that device will send to
    client.send '/sys/port', port
    # get the device info
    client.send '/sys/info', port
    # we are ready to receive device info
    grid.emit 'listening'

  handlePrefix = (msg)->
    prefix      = msg[1]
    setLedAddr  = prefix + '/grid/led/set'
    keyAddr     = prefix + '/grid/key'

  handleSize = (msg)->
    width   = msg[1]
    height  = msg[2]

  handleKey = (msg)->
    x = msg[1]
    y = msg[2]
    i = msg[3]
    client.send(setLedAddr, x, y, i)

  # Public Methods
  grid.close = ->
    if server then server.kill()

  Object.defineProperty grid, 'width', get: -> width
  Object.defineProperty grid, 'height', get: -> height

  return grid
