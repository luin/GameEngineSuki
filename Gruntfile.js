module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      compile: {
        options: {
          bare: false,
          sourceMap: true
        },
        files: {
          'build/suki.js': [
            'src/Suki.coffee',
            'src/Base.coffee',
            'src/Event.coffee',
            'src/Timer.coffee',
            'src/Entity.coffee',
            'src/Scene.coffee',
            'src/Stage.coffee',
            'src/util.coffee'
          ]
        }
      }
    },
    uglify: {
      compile: {
        options: {
          sourceMap: 'build/suki.min.js.map',
          sourceMapIn: 'build/suki.js.map',
          report: 'gzip'
        },
        files: {
          'build/suki.min.js': ['build/suki.js']
        }
      }
    }
  });
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask('default', []);
  grunt.registerTask('build', ['coffee', 'uglify']);
};

