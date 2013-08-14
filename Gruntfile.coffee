###
monome
https://github.com/charlesholbrow/grunt

Copyright (c) 2013 Charles Holbrow
Licensed under the MIT license.
###

module.exports = (grunt)->
  'use strict'

  _ = grunt.util._
  path = require 'path'

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    coffeelint:
      gruntfile:
        src: 'Gruntfile.coffee'
      lib:
        src: ['src/lib/**/*.coffee']
      test:
        src: ['src/test/**/*.coffee']
      options:
        no_trailing_whitespace:
          level: 'error'
        max_line_length:
          level: 'warn'
    coffee:
      lib:
        expand: true
        cwd: 'src/lib/'
        src: ['**/*.coffee']
        dest: 'out/lib/'
        ext: '.js'
      test:
        expand: true
        cwd: 'src/test/'
        src: ['**/*.coffee']
        dest: 'out/test/'
        ext: '.js'
    simplemocha:
      all:
        src: [
          'node_modules/should/lib/should.js'
          'out/test/**/*.js'
        ]
        options:
          globals: ['should']
          timeout: 3000
          ignoreLeaks: false
          ui: 'bdd'
          reporter: 'spec'
    watch:
      options:
        spawn: false
      gruntfile:
        files: '<%= coffeelint.gruntfile.src %>'
        tasks: ['coffeelint:gruntfile']
      lib:
        files: '<%= coffeelint.lib.src %>'
        tasks: ['coffeelint:lib', 'coffee:lib', 'simplemocha']
      test:
        files: '<%= coffeelint.test.src %>'
        tasks: ['coffeelint:test', 'coffee:test', 'simplemocha']
    clean: ['out/']

  # plugins.
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.event.on 'watch', (action, files, target)->
    grunt.log.writeln "#{target}: #{files} has #{action}"

    # coffeelint
    grunt.config ['coffeelint', target], src: files

    # coffee
    coffeeData = grunt.config ['coffee', target]
    files = [files] if _.isString files
    files = _.map files, (file)-> path.relative coffeeData.cwd, file
    coffeeData.src = files

    grunt.config ['coffee', target], coffeeData

  # tasks.
  grunt.registerTask 'compile', [
    'coffeelint'
    'coffee'
  ]

  grunt.registerTask 'test', [
    'simplemocha'
  ]

  grunt.registerTask 'default', [
    'compile'
    'test'
  ]

