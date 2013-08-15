###
monome
https://github.com/charlesholbrow/grunt

Copyright (c) 2013 Charles Holbrow
Licensed under the MIT license.
###


'use strict'


osc = require 'node-osc'
events = require 'events'
makeGrid = require './grid'

# devices by id
module.exports.devices = devices = {}

module.exports.init = ->

  listen = new osc.Server 3333, '127.0.0.1'
  discovery = new osc.Client '127.0.0.1', 12002

  listen.on 'message', (msg, info)->
    address = msg[0]

    # receiving device info
    # makeDevice only if we need to
    if address == '/serialosc/device'
      id = msg[1]
      type = msg[2]
      port = msg[3]
      unless devices[id]
        console.log '---Found Device---'
        console.log 'device:', msg, '\n'
        devices[id] = makeGrid(port, type)

    # a new device has been added
    # do we need to request the device list to get device info?
    else if address == '/serialosc/add'
      id = msg[1]
      unless devices[id] then discovery.send '/serialosc/list', '127.0.0.1', 3333

    # delete the device on unplug
    else if address == '/serialosc/remove'
      console.log 'remove'
      id = msg[1]
      if devices[id]
        console.log '---Remove Device---'
        console.log 'device:', msg, '\n'
        delete devices[id]

    console.log '---Message---'
    console.log 'info:', info
    console.log 'msg: ', msg
    console.log '---devices---'
    console.log devices
    console.log ''


  discovery.send '/serialosc/list', '127.0.0.1', 3333
  discovery.send '/serialosc/notify', '127.0.0.1', 3333

