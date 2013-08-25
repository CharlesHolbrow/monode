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

## Documentation
When a device is connected, monome triggers a 'connect' event
```
var nodeMonome = require('node-monome');
var monome = nodeMonome(); // initialize

// light grid led on key press
monome.on('connect', function(device) {
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

### device
```
// Read-only properties
device.width  // integer
device.height // integer
device.host   // string
device.port   // integer
device.id     // string ex: "m0000164"
device.type   // string ex: "monome arc 2", "monome 64"
device.isArc  // bool
device.osc    // [node-osc client](https://github.com/TheAlphaNerd/node-osc)

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
```

### device events
```
tilt // arc,grid
enc // arc only
key // grid or arc2011
disconnect
prefix
rotation
ready // consider removing this
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History
_(Nothing yet)_

## License
Copyright (c) 2013 Charles Holbrow  
Licensed under the MIT license.
