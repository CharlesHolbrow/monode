# node-monome

monome and arc toolkit in node.js
required serialosc 1.2a or later
arc support coming soon

## Getting Started
```
npm install node-monome
```
```
var monome = require('node-monome')();

// light on key press
monome.on('connect', function(device) {
  device.on('key', function(x, y, i) {
    device.led(x, y, i);
  });
});

```

## Documentation

### device
device.width
device.height
device.host
device.port
device.id
device.rotation // set or get
device.prefix // set or get

// set prefix by assigning 0, 90, 180, 270 (asynchronous)
device.rotation; // returns 90
device.rotation = 180;
device.rotation; // returns 90
device.on('rotation', function(value){
  console.log('rotation changed to:', rotation);
});

// turn on an led
device.led(3, 4, 1);
// turn off
device.led(3, 4, 0);

## Examples
_(Coming soon)_

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History
_(Nothing yet)_

## License
Copyright (c) 2013 Charles Holbrow  
Licensed under the MIT license.
