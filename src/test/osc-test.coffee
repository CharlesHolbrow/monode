'use strict'

nodeOsc = require 'node-osc'
osc     = require '../lib/osc'

console.log osc.toString()

describe 'osc', ->

  describe 'Server', ->
    it 'should create an instance of node-osc.Server', (done)->
      @timeout 300
      osc.Server null, (err, server)->
        server.should.be.an.instanceOf nodeOsc.Server
        console.log('found port', server.port)
        done err

    it 'should skip udp ports that fail the "listen test"', (done)->
      @timeout 300
      dummy = new nodeOsc.Server 9091, 'localhost'
      osc.Server 9091, (err, server)->
        server.port.should.be.above 9091
        console.log('found port', server.port)
        done(err)

  describe 'Client', ->
    it 'should be an instance of node-osc.Client', ->
      client = new osc.Client(10109)
      client.should.be.an.instanceOf nodeOsc.Client

    it 'should accept a port number as constructor agrument', (done)->
      @timeout 200
      rand = 'test' + Math.random()

      listener  = new nodeOsc.Server 10110, 'localhost'
      listener.on 'message', (msg)->
        if msg[1] == rand then done()

      client = new osc.Client 10110
      client.send '/random/test', rand
