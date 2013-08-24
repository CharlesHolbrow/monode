monome = require('./monome')()
monome.on 'connect', (device)->
  device.on 'key', (x, y, i)->
    device.led(x, y, i)
