events  = require 'events'
osc     = require './osc'
nodeOsc = require 'node-osc'

module.exports = makeGrid = (devicePort, type)->
  grid        = new events.EventEmitter()  # object to be returned
  server      = null # create this once we have a port
  setLedAddr  = null
  keyAddr     = null
  encAddr     = null
  tiltAddr    = null

  # exposed with getters
  client      = new nodeOsc.Client('localhost', devicePort) # device.osc
  isArc       = !!(type and type.match /monome arc.*/)
  prefix      = null
  width       = null
  height      = null
  port        = null
  id          = null
  host        = null
  rotation    = null
  ready       = false

  new osc.Server 10200, (error, _server)->
    if error
      console.error 'Error creating grid server:', error
      throw error
    server = _server
    port = server.port
    server.on 'message', (msg, info)->
      address = msg[0]
      return unless address # an address is required
      if address == '/sys/prefix' then handlePrefix(msg)
      else if address == keyAddr then handleKey(msg)
      else if address == encAddr then handleEnc(msg)
      else if address == tiltAddr then handleTilt(msg)
      else if address == '/sys/size' then handleSize(msg)
      else if address == '/sys/id' then handleId(msg)
      else if address == '/sys/host' then handleHost(msg)
      else if address == '/sys/rotation' then handleRotation(msg)
      else if address == '/sys/disconnect' then handleDisconnect(msg)
    # we are ready to receive device info
    grid.emit 'listening', server.port
    # Set default port that device will send to
    client.send '/sys/port', port
    # get the device info
    client.send '/sys/info', port

  handlePrefix = (msg)->
    prefix        = msg[1]
    tiltAddr      = prefix + 'tilt'
    if isArc
      keyAddr     = prefix + '/ring/key'
      setLedAddr  = prefix + '/ring/set'
      encAddr     = prefix + '/enc/delta'
    else # assume grid
      keyAddr     = prefix + '/grid/key'
      setLedAddr  = prefix + '/grid/led/set'
    grid.emit 'prefix', prefix
    isReady()
  handleSize = (msg)->
    width   = msg[1]
    height  = msg[2]
    grid.emit 'size', width, height
    isReady()
  handleId =  (msg)->
    id = msg[1]
    grid.emit 'id', id
    isReady()
  handleHost = (msg)->
    host = msg[1]
    grid.emit 'host', host
    isReady()
  handleRotation = (msg)->
    rotation = msg[1]
    grid.emit 'rotation', rotation
    isReady()
  handleDisconnect = (msg)->
    grid.emit 'disconnect'
  handleKey = (msg)->
    grid.emit 'key', msg[1], msg[2], msg[3]
  handleEnc = (msg)->
    grid.emit 'enc', msg[1], msg[2]
  handleTilt = (msg)->
    grid.emit 'tilt', msg[1], msg[2], msg[3]
  isReady = ->
    if not ready
      if height != null and rotation != null and
      port and id and host and prefix
        ready = true
        grid.emit 'ready'

  # Public Methods
  grid.led = (x, y, i)->
    client.send(setLedAddr, x, y, i)
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
    set: (value)-> client.send '/sys/rotation', value
    enumerable: true
  Object.defineProperty grid, 'id',
    get: -> id
    enumerable: true
  Object.defineProperty grid, 'host',
    get: -> host
    enumerable: true
  Object.defineProperty grid, 'port',
    get: -> port
    enumerable: true
  Object.defineProperty grid, 'prefix',
    get: -> prefix
    set: (value)-> client.send '/sys/prefix', value
    enumerable: true
  Object.defineProperty grid, 'ready',
    get: -> ready
    enumerable: true
  Object.defineProperty grid, 'osc',
    get: -> client
    enumerable: true
  Object.defineProperty grid, 'type',
    get: -> type
    enumerable: true
  Object.defineProperty grid, 'isArc',
    get: -> isArc
    enumerable: true

  return grid
