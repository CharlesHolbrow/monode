# monode

monome grid/arc toolkit

Monode makes monome device discovery/interaction trivial and fun. [lol wut?](http://monome.org)

## Getting Started
```
$ npm install monode
$ node
> monode = require('monode')();
// now plug your monome grid in
> monode.grid.led(0, 0, 1);
// now plug your arc in
> monode.arc.led(0, 0, 1);   // turn on
> monode.arc.level(0, 1, 8); // set level
```

## Getting Started With Better Practices
monode emits a 'device' event when a monome device is ready to use.

- "device" triggers after a device is connected via usb
- "device" triggers once for each connected device after `monodeInit` is called for the first time

```
// light grid led on key press
var monodeInit = require('monode');
var monode = monodeInit();

monode.on('device', function(device) {
  device.on('key', function(x, y, s) {
    device.led(x, y, s);
  });
});
```

Connected devices also accessible through the monode.devices object
```
console.log('Device IDs:', Object.keys(monode.devices));
```

# Documentation
## Device Methods
#### device.led(x, y, state)
```
// turn on led at position 0, 4
device.led(0, 4, 1);
// turn off again
device.led(0, 4, 0);
```

#### device.level(x, y, intensity)
```
// set led level IF the device supports it
device.level(0, 0, 8)
```

#### device.close()
```
// close the server listening for messages from the device
// in most cases, you won't need this as it will happen
// automagically when you exit node.js
device.close()
```

#### device.osc.send(address, val1, val2, ...)
```
// send arbitrary osc message to serialosc
device.osc.send(device.prefix + '/grid/led/all', 1);
```

## Device Properties
```
// Read-only properties
device.width  // integer - for arc, this is the same as size
device.height // integer - for arc this is always 64
device.host   // string
device.port   // integer
device.id     // string ex: "m0000164"
device.type   // string ex: "monome arc 2", "monome 64"
device.isArc  // bool
device.ready  // bool
device.size   // integer, arc only, 2 or 4
device.osc    // [node-osc Client](https://github.com/TheAlphaNerd/node-osc)

// Assignable properties
device.rotation // integer - grid only - 0, 90, 180, or 270
device.prefix   // string - set or get

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
```

## Device Events
#### enc 
```
// arc encoder delta
device.on('enc', function(n, delta){
  console.log('Arc turn:', n, delta);
});
```

#### key
```
// grid and arc 2011
device.on('key', function(x, y, s){
  if (device.isArc) console.log('Arc push:', x, y);
  else console.log('Grid Key:', x, y, s);
});
```

#### tilt
```
// arc or grid
device.on('tilt', function(n, x, y, z){
  console.log('tilt:', n, x, y, z);
});
```

#### disconnect 
```
// similar to the monode "disconnect" event
device.on('disconnect', function(device){
  console.log('device disconnected:', device);
});
```

#### prefix and rotation
```
// prefix and rotation work the same way
device.on('prefix', function(prefix){
  console.log('prefix changed to:', prefix);
});
```

#### ready
```
// ready is similar to the monode "device" event
// use the monode "device" event to get devices...
device.on('ready', function(device){
  // assert(device.ready);
  // assert(device.width);
  console.log('device is ready:', device);
});
```

## monode Properties
#### monode.grid
A convenience property -- the most recently added monome grid. Usefull when fooling around in the console.

#### monode.arc
A convenience property -- the most recently added monome arc.

## monode Events
#### device
```
// triggered once the device has configured itself with width, height, etc
monode.on('device', function(device){
  console.log('A device was connected, and is ready to use')
  console.log('Port:', device.port);
  console.log('Dimentions:', device.width, device.height)
});
```

#### connect
```
// not recomended - just use "device" instead
monode.on('connect', function(device){
  // port, width, height will still be undefinded
  console.log('a device was connected:', device);
  device.on('ready', function(){
    console.log('Yay, now we can use it!');
  });
});
```

#### disconnect
```
monode.on('disconnect', function(device){
  console.log('A device was disconnected:', device);
})
```

# Misc
## Requires serialosc 1.2a or later
[mac](http://monome.org/docs/setup:mac) 
[win](http://monome.org/docs/setup:win) 
[linux](http://monome.org/docs/setup:linux) 

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History

- 2.2.1 Smarter detection of open UDP ports  
- 2.2.0 Add monode.grid and monode.arc convenience properties  
- 2.1.1 Improve documentation  
- 2.1.0 add device.level method for arc and grid  
- 2.0.0 rename node-monome to monode  
- 1.1.2 Better Readme  
- 1.1.1 Bugfixes  
- 1.1.0 Add Arc Support  

## License
Copyright (c) 2013 Charles Holbrow  
Licensed under the MIT license.
