# node-monome
monome and arc toolkit in node.js
requires serialosc 1.2a or later

## Getting Started
```
$ npm install node-monome
$ node
> var nodeMonome = require('node-monome');
> var monome = nodeMonome(); // initialize
```

# Documentation
When a device is connected and ready to use, monome triggers a 'device' event
```
var nodeMonome = require('node-monome');
var monome = nodeMonome(); // initialize

// light grid led on key press
monome.on('device', function(device) {
  device.on('key', function(x, y, i) {
    device.led(x, y, i);
  });
});
```

Connected devices are stored in the devices object
```
// keys are a device id, such as 'm0000115'
// values are device objects as described below
monome.devices
```

## Device
### Device Properties
```
// Read-only properties
device.width  // integer - for arc, this is the same as size
device.height // integer - for arc this is always 64
device.host   // string
device.port   // integer
device.id     // string ex: "m0000164"
device.type   // string ex: "monome arc 2", "monome 64"
device.isArc  // bool
device.size   // integer, arc only, 2 or 4
device.osc    // [node-osc Client](https://github.com/TheAlphaNerd/node-osc)

// Assignable properties
device.rotation //  0, 90, 180, or 270
device.prefix // set or get

// Assignable properties update asynchronously.
// An event will be fired when when the update occurs.
// Set rotation by assigning 0, 90, 180, 270
> device.on('rotation', function(value){
>  console.log('rotation changed to:', value);
> });
> console.log(device.rotation);
90
> device.rotation = 180; console.log(device.rotation);
90
rotation changed to: 180

// turn on led at position 3, 4
device.led(3, 4, 1);
// turn off led
device.led(3, 4, 0);

// send arbitrary osc message to serialosc
device.osc.send(device.prefix + '/grid/led/all', 1)
```

### Device Events
```
// tilt - arc or grid
device.on('tilt', function(n, x, y, z){
  console.log('tilt:', n, x, y, z);
});

// encoder delta - arc only
device.on('enc', function(n, delta){
  console.log('Arc turn:', n, delta);
});

// key - grid or arc2011
device.on('key', function(x, y, s){
  if (device.isArc) console.log('Push:', x, y);
  else console.log('Grid Key:', x, y, s);
});

// disconnect is similar to monome.disconnect
device.on('disconnect', function(device){
  console.log('device disconnected:', device);
});

// prefix and rotation work the same way
device.on('prefix', function(prefix){
  console.log('prefix changed to:', prefix);
});

// ready is similar to monome.ready
device.on('ready', function(device){
  // assert(device.ready);
  console.log('device is ready:', device);
});
```

## monome
### monome Events
```
// connect
monome.on('connect', function(device){
  console.log('a device was connected:', device);
})
// disconnect
monome.on('disconnect', function(device){
  console.log('A device was disconnected:', device);
})
// device - triggered once the device has configured itself with width, height, etc
monome.on('device', function(device){
  console.log('A device was connected, and is ready to use')
  console.log('Port:', device.port);
  console.log('Dimentions:', device.width, device.height)
});
```

# Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

# Release History
1.1.0 Add Arc Support

# License
Copyright (c) 2013 Charles Holbrow  
Licensed under the MIT license.
