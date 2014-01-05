module.exports =(grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    concat:
      build:
        src: [
          'src/Suki.coffee'
          'src/Base.coffee'
          'src/Event.coffee'
          'src/Timer.coffee'
          'src/Entity.coffee'
          'src/Layer.coffee'
          'src/Scene.coffee'
          'src/Stage.coffee'
          'src/Vector.coffee'
          'src/components/*.coffee'
        ]
        dest: 'build/suki.coffee'
      test:
        src: [
          'test/suki.header'
          'build/suki.test.js'
          'test/suki.footer'
        ]
        dest: 'build/suki.test.js'
    coffee:
      build:
        files:
          'build/suki.js': 'build/suki.coffee'
      test:
        options:
          bare: true
        files:
          'build/suki.test.js': 'build/suki.coffee'
    uglify:
      build:
        options:
          sourceMap: 'build/suki.min.js.map'
          report: 'gzip'
        files:
          'build/suki.min.js': ['build/suki.js']
    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: 'should'
          growl: true
        src: ['test/**/*.coffee']
    clean:
      build: ['build/suki.coffee']
      test: ['build/*.test.*']
    watch:
      scripts:
        files: ['test/**/*.coffee', 'src/**/*.coffee']
        tasks: ['build', 'test']
    coffeelint:
      options:
        configFile: 'coffeelint.json'
      app: ['test/**/*.coffee', 'src/**/*.coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-coffeelint'

  grunt.registerTask 'default', []
  grunt.registerTask 'build', ['concat:build', 'coffee:build', 'uglify', 'clean:build']
  grunt.registerTask 'test',
    ['concat:build', 'coffee:test', 'concat:test', 'mochaTest:test', 'coffeelint', 'clean:test']

