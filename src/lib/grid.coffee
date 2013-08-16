events      = require 'events'
portscanner = require 'portscanner'
osc         = require 'node-osc'


module.exports = makeGrid = (devicePort)->
  grid        = new events.EventEmitter()  # object to be returned
  client      = new osc.Client('localhost', devicePort)
  server      = null # create this once we have a port
  prefix      = null
  setLedAddr  = null
  keyAddr     = null
  width       = undefined
  height      = undefined
  port        = 10100

  Object.defineProperty grid, 'width', get: -> width
  Object.defineProperty grid, 'height', get: -> height

  server = new osc.Server(port, 'localhost')
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

  return grid
