module.exports = function(config) {
	config.set({

		autoWatch: true,

		basePath: './',

		browsers: ['PhantomJS'],

		files: [
			'../../js/*.js',
			'node_modules/angular/angular.js',
			'node_modules/angular-mocks/angular-mocks.js',
			'build/demo.json',
			'node_modules/angular/angular.js',
			'node_modules/angular-animate/angular-animate.js',
			'node_modules/angular-sanitize/angular-sanitize.js',
			'build/assets/lib/createjs.js',
			'build/assets/lib/modernizr.js',
			'build/assets/lib/hammer.min.js',
			'build/assets/lib/angular-hammer.min.js',
			'build/assets/lib/draw.js',
			'build/modules/main.js',
			'build/directives/*.js',
			'build/factories/*.js',
			'build/controllers/creator.js',
			'build/controllers/player.js',
			'tests/*.js'
		],

		frameworks: ['jasmine'],

		plugins: [
			'karma-coverage',
			'karma-eslint',
			'karma-jasmine',
			'karma-json-fixtures-preprocessor',
			'karma-mocha-reporter',
			'karma-phantomjs-launcher'
		],

		preprocessors: {
			'build/controllers/player.js': ['coverage', 'eslint'],
			'build/factories/*.js': ['coverage', 'eslint'],
			'build/demo.json': ['json_fixtures']
		},

		//plugin-specific configurations
		eslint: {
			stopOnError: true,
			stopOnWarning: false,
			showWarnings: true,
			engine: {
				configFile: '.eslintrc.json'
			}
		},

		jsonFixturesPreprocessor: {
			variableName: '__demo__'
		},

		reporters: ['coverage', 'mocha'],

		//reporter-specific configurations

		coverageReporter: {
			check: {
				global: {
					statements: 100,
					branches:   80,
					functions:  90,
					lines:      90
				},
				each: {
					statements: 100,
					branches:   80,
					functions:  90,
					lines:      90
				}
			},
			reporters: [
				{ type: 'html', subdir: 'report-html' },
				{ type: 'cobertura', subdir: '.', file: 'coverage.xml' }
			]
		},

		junitReporter: {
			outputFile: './test_out/unit.xml',
			suite: 'unit'
		},

		mochaReporter: {
			output: 'autowatch'
		}

	});
};
