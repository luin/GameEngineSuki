module.exports =(grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    concat:
      dist:
        src: [
          'src/Suki.coffee'
          'src/Base.coffee'
          'src/Event.coffee'
          'src/Timer.coffee'
          'src/Entity.coffee'
          'src/Scene.coffee'
          'src/Stage.coffee'
          'src/util.coffee'
          'src/components/*.coffee'
        ]
        dest: 'build/suki.coffee'
    coffee:
      compile:
        options:
          bare: false,
          sourceMap: true
        files:
          'build/suki.js': 'src/suki.coffee'
    uglify:
      compile:
        options:
          sourceMap: 'build/suki.min.js.map'
          sourceMapIn: 'build/suki.js.map'
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
    watch:
      scripts:
        files: ['test/**/*.coffee', 'src/**/*.coffee']
        tasks: ['concat', 'mochaTest:test', 'coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', []
  grunt.registerTask 'build', ['concat', 'coffee', 'uglify']
  grunt.registerTask 'test', ['concat', 'mochaTest:test']

