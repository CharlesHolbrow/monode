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

monome  = undefined
PORT    = 45450

module.exports = ->
  if monome then return monome
  listen = null
  monome = new events.EventEmitter()
  monome.devices = devices = {}
  serialosc = osc.Client 12002

  osc.Server PORT, (error, _listen)->
    listen = _listen
    if error
      throw new Error('Failed to open main server: ' + error)
    if listen.port != PORT
      throw new Error('Failed to listen on udp port ' + PORT +
      '. Is node-monome already running?')

    # listen to serialosc
    listen.on 'message', (msg, info)->

      # receive device info
      if msg[0] == '/serialosc/device' or msg[0] == '/serialosc/add'
        id = msg[1]
        type = msg[2]
        port = msg[3]
        unless devices[id]
          console.log 'Connect:', msg, '\n'
          device = makeGrid port, type
          devices[id] = device
          device.once 'ready', ->
            monome.emit 'device', device
          # store newly added devices in convenience properties
          if type.match /monome arc \d+/
            monome.arc = device
          else
            monome.grid = device
          monome.emit 'connect', device


      # device was removed
      if msg[0] == '/serialosc/remove'
        id = msg[1]
        device = devices[id]
        if device
          console.log 'Disconnect:', msg, '\n'
          monome.emit 'disconnect', device
          device.close()
          delete devices[id]

      # we need to request notification again
      if msg[0] == '/serialosc/add' or msg[0] == '/serialosc/remove'
        serialosc.send '/serialosc/notify', '127.0.0.1', PORT

    # get a list of all the connected devices
    serialosc.send '/serialosc/list', '127.0.0.1', PORT
    serialosc.send '/serialosc/notify', '127.0.0.1', PORT
  return monome
