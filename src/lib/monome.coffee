###
monome
https://github.com/charlesholbrow/node-monome

Copyright (c) 2013 Charles Holbrow
Licensed under the MIT license.
###

'use strict'

events    = require 'events'
makeGrid  = require './grid'
osc       = require './osc'

PORT = 3333
monome = null
devices = null

module.exports = ->
  if monome then return monome
  monome = new events.EventEmitter()
  monome.devices = devices

  devices = {} # devices by id
  serialosc = osc.Client 12002

  osc.Server PORT, (error, listen)->
    if error
      throw new Error('Failed to open main server: ' + error)
    if listen.port != PORT
      throw new Error('Failed to listen on udp port ' + port +
      '. Is node-monome already running?')

    # listen to serialosc
    listen.on 'message', (msg, info)->
      # receive device info
      if msg[0] == '/serialosc/device'
        id = msg[1]
        type = msg[2]
        port = msg[3]
        if devices[id]
          devices[id].emit 'disconnect'
          devices[id].removeAllListeners()
          if devices[id] then delete devices[id]
        console.log 'Connect:', msg, '\n'
        device = makeGrid(port, type)
        devices[id] = device
        device.on 'disconnect', (id)->
          if devices[id]
            console.log 'Disconnect:', msg, '\n'
            delete devices[id]
      # a new device connected
      else if msg[0] == '/serialosc/add'
        id = msg[1]
        unless devices[id]
          serialosc.send '/serialosc/list', '127.0.0.1', PORT

    # get a list of all the connected devices
    serialosc.send '/serialosc/list', '127.0.0.1', PORT
    serialosc.send '/serialosc/notify', '127.0.0.1', PORT
  return monome

module.exports.devices = devices
