const path = require('path')
const srcPath = path.join(__dirname, 'src') + path.sep
const outputPath = path.join(__dirname, 'build')
const widgetWebpack = require('materia-widget-development-kit/webpack-widget')
const ModernizrWebpackPlugin = require('modernizr-webpack-plugin');

const entries = widgetWebpack.getDefaultEntries()
const copy = widgetWebpack.getDefaultCopyList()

entries['player.js'] = [
	srcPath+'draw.coffee',
	srcPath+'player.coffee'
]
entries['assets/lib/draw.js'] = [srcPath+'draw.coffee']
entries['assets/lib/angular-hammer.min.js'] = [srcPath+'angular-hammer.js']

// copy libs from node_modules to libs dir
const customCopy = copy.concat([
	{
		from: path.join(__dirname, 'node_modules', 'hammerjs', 'dist', 'hammer.min.js'),
		to: path.join(__dirname, 'build', 'assets', 'lib')
	},
	{
		from: path.join(__dirname, 'node_modules', 'createjs', 'builds', 'createjs-2013.12.12.min.js'),
		to: path.join(__dirname, 'build', 'assets', 'lib', 'createjs.js')
	}
])

let options = {
	entries: entries,
	copyList: customCopy
}

const webpackConfig = widgetWebpack.getLegacyWidgetBuildConfig(options)

const modernizrConfig = {
	noChunk: true,
	filename: 'assets/lib/modernizr.js',
	'options':[
		'domprefixes',
		'prefixes',
		'setclasses',
		"html5shiv",
		"testAllProps",
		"testProp",
		"testStyles"
	],
	'feature-detects': [
		'css/borderradius',
		'css/animations',
		'css/transforms',
		'css/transforms3d',
		'css/transitions',
		'css/fontface',
		'css/generatedcontent',
		'input',
		'css/opacity',
		'css/rgba'
	],
	minify: {
		output: {
			comments: true,
			beautify: false
		}
	}
}

webpackConfig.plugins.push(new ModernizrWebpackPlugin(modernizrConfig))

module.exports = webpackConfig
