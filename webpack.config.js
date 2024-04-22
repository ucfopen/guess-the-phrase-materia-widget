const fs = require('fs')
const path = require('path')
const widgetWebpack = require('materia-widget-development-kit/webpack-widget')
const srcPath = path.join(__dirname, 'src') + path.sep
const outputPath = path.join(__dirname, 'build') + path.sep

const copy = widgetWebpack.getDefaultCopyList()

const rules = widgetWebpack.getDefaultRules()

const customDoNothingToJs = rules.loaderDoNothingToJs
customDoNothingToJs.test = /(?:player|creator)\.js$/

const customReactLoader = {
	test: /scorescreen.*\.js$/i,
	exclude: /node_modules/,
	use: {
		loader: 'babel-loader'
	}
}

let customRules = [
	rules.loaderCompileCoffee,
	rules.copyImages,
	rules.loadHTMLAndReplaceMateriaScripts,
	rules.loadAndPrefixSASS,
	customReactLoader
]

const entries = {
	'creator': [
		path.join(srcPath, 'creator.html'),
		path.join(srcPath, 'angular-hammer.js'),
		path.join(srcPath, 'creator.coffee'),
		path.join(srcPath, 'creator.scss'),
	],
	'player': [
		path.join(srcPath, 'player.html'),
		path.join(srcPath, 'angular-hammer.js'),
		path.join(srcPath, 'draw.coffee'),
		path.join(srcPath, 'player.coffee'),
		path.join(srcPath, 'player.scss')
	],
	'scorescreen': [
		path.join(srcPath, 'scorescreen.html'),
		path.join(srcPath, 'scorescreen.js'),
		path.join(srcPath, 'scorescreen.scss')
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
	entries: entries,
	moduleRules: customRules
}

let buildConfig = widgetWebpack.getLegacyWidgetBuildConfig(options)

buildConfig.externals = {
	"react": "React",
	"react-dom": "ReactDOM"
}

module.exports = buildConfig
