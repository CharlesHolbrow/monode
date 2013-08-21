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

  # exposed with getters
  width       = null
  height      = null
  port        = null
  id          = null
  host        = null
  rotation    = null

  new osc.Server 10200, (error, _server)->
    if error
      console.log 'Error creating grid server:', error
      throw error
    server = _server
    port = server.port
    server.on 'message', (msg, info)->
      address = msg[0]
      if address == '/sys/prefix' then handlePrefix(msg)
      else if address == '/sys/size' then handleSize(msg)
      else if address == '/sys/id' then handleId(msg)
      else if address == '/sys/host' then handleHost(msg)
      else if address == '/sys/rotation' then handleHandle(msg)
      else if address == keyAddr
        handleKey(msg)
    # we are ready to receive device info
    grid.emit 'listening', server.port
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
  handleId =  (msg)->
    id = msg[1]
  handleHost = (msg)->
    host = msg[1]
  handleRotation = (msg)->
    rotation = msg[1]

  handleKey = (msg)->
    x = msg[1]
    y = msg[2]
    i = msg[3]
    client.send(setLedAddr, x, y, i)

  # Public Methods
  grid.close = ->
    if server then server.kill()

  Object.defineProperty grid, 'width',
    get: -> width
    enumerable: true
  Object.defineProperty grid, 'height',
    get: -> height,
    enumerable: true
  Object.defineProperty grid, 'rotation',
    get: -> rotation
    enumerable: true
  Object.defineProperty grid, 'id',
    get: -> id
    enumerable: true
  Object.defineProperty grid, 'host',
    get: -> host
    enumerable: true

  return grid
