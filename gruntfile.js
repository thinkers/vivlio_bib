module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-compass');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-serve');
  grunt.initConfig({
	connect: {
		options: {
			middleware: function(connect, options) {
				return [
					function(req, res, next) {
						res.setHeader('Access-Control-Allow-Origin', '*');
						res.setHeader('Access-Control-Allow-Methods', 'GETUTOST,DELETE');
						res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
						return next();
					},
					connect.static(require('path').resolve('.'))
				];
			},
			hostname: '0.0.0.0',
			port: 9000
		}
	},
    serve: {
        options: {
			middleware: function(connect, options) {
				return [
					function(req, res, next) {
						res.setHeader('Access-Control-Allow-Origin', '*');
						res.setHeader('Access-Control-Allow-Methods', 'GETUTOST,DELETE');
						res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
						return next();
					},
					connect.static(require('path').resolve('.'))
				];
			},
            port: 9000
        }
    },
    uglify: {
      my_target: {
        files: {
          '_/js/script.js': ['_/components/js/*.js']
        } //files
      } //my_target
    }, //uglify task
    compass: {
      dev: {
        options: {
          config: 'config.rb'
        } //options
      } //dev
    }, //compass task
    watch: {
      options: { livereload: true },
      scripts: {
        files: ['_/components/js/*.js'],
        tasks: ['uglify']
      }, //script
      sass: {
        files: ['_/components/sass/*.scss'],
        tasks: ['compass:dev']
      }, //sass task
      html: {
        files: ['*.html']
      }
    } //watch
  }); //initConfig
  grunt.registerTask('default', 'watch');
}; //exports
