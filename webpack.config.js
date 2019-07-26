const fs = require('fs')
const path = require('path')
const widgetWebpack = require('materia-widget-development-kit/webpack-widget')
const ModernizrWebpackPlugin = require('modernizr-webpack-plugin');
const srcPath = path.join(__dirname, 'src') + path.sep
const outputPath = path.join(__dirname, 'build') + path.sep

const copy = widgetWebpack.getDefaultCopyList()

const entries = {
	'creator.js': [
			path.join(srcPath, 'creator.coffee'),
	],
	'player.js': [
			path.join(srcPath, 'draw.coffee'),
			path.join(srcPath, 'player.coffee')
	],
	'assets/lib/draw.js': [
			path.join(srcPath, 'draw.coffee')
	],
	'assets/lib/angular-hammer.min.js': [
			path.join(srcPath, 'angular-hammer.js')
	],
	'creator.css': [
			path.join(srcPath, 'creator.html'),
			path.join(srcPath, 'creator.scss')
	],
	'player.css': [
			path.join(srcPath, 'player.html'),
			path.join(srcPath, 'player.scss')
	],
	'guides/player.temp.html': [
			path.join(srcPath, '_guides', 'player.md')
	],
	'guides/creator.temp.html': [
			path.join(srcPath, '_guides', 'creator.md')
	]
}

const customCopy = copy.concat([
	{
		from: path.join(srcPath, '_guides', 'assets'),
		to: path.join(outputPath, 'guides', 'assets'),
		toType: 'dir'
	},
	{
		from: path.join(__dirname, 'node_modules', 'hammerjs', 'dist', 'hammer.min.js'),
		to: path.join(outputPath, 'assets', 'lib')
	},
	{
		from: path.join(__dirname, 'node_modules', 'createjs', 'builds', 'createjs-2013.12.12.min.js'),
		to: path.join(outputPath, 'assets', 'lib', 'createjs.js')
	}
])

const options = {
	copyList: customCopy,
	entries: entries
}

let buildConfig = widgetWebpack.getLegacyWidgetBuildConfig(options)

const modernizrConfig = {
	noChunk: true,
	filename: 'assets/lib/modernizr.js',
	'options':[
		'domPrefixes',
		'prefixes',
		'setClasses',
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

buildConfig.plugins.unshift(new ModernizrWebpackPlugin(modernizrConfig))

module.exports = buildConfig
