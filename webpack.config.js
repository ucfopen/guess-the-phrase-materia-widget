const fs = require('fs')
const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const marked = require('meta-marked')
const widgetWebpack = require('materia-widget-development-kit/webpack-widget')
const ModernizrWebpackPlugin = require('modernizr-webpack-plugin');

const rules = widgetWebpack.getDefaultRules()
const copy = widgetWebpack.getDefaultCopyList()

const entries = {
	'creator.js': [
		path.join(__dirname, 'src', 'draw.coffee'),
		path.join(__dirname, 'src', 'creator.coffee')
	],
	'player.js': [
		path.join(__dirname, 'src', 'draw.coffee'),
		path.join(__dirname, 'src', 'player.coffee')
	],
	'creator.css': [
		path.join(__dirname, 'src', 'creator.html'),
		path.join(__dirname, 'src', 'creator.scss')
	],
	'player.css': [
		path.join(__dirname, 'src', 'player.html'),
		path.join(__dirname, 'src', 'player.scss')
	],
	'guides/guideStyles.css': [
		path.join(__dirname, 'src', '_helper-docs', 'guideStyles.scss')
	]
}

// copy libs from node_modules to libs dir
const srcPath = path.join(process.cwd(), 'src')
const outputPath = path.join(process.cwd(), 'build')

const customCopy = copy.concat([
	{
		from: `${srcPath}/_helper-docs/assets`,
		to: `${outputPath}/guides/assets`,
		toType: 'dir'
	},
	{
		from: path.join(__dirname, 'node_modules', 'hammerjs', 'dist', 'hammer.min.js'),
		to: path.join(__dirname, 'build', 'assets', 'lib')
	},
	//maybe take below out?
	// {
	// 	from: path.join(__dirname, 'node_modules', 'createjs', 'builds', 'createjs-2013.12.12.min.js'),
	// 	to: path.join(__dirname, 'build', 'assets', 'lib', 'createjs.js')
	// }
])

const options = {
	copyList: customCopy,
	entries: entries
}

const webpackConfig = widgetWebpack.getLegacyWidgetBuildConfig(options)

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

webpackConfig.plugins.push(new ModernizrWebpackPlugin(modernizrConfig))

const generateHelperPlugin = name => {
	const file = fs.readFileSync(path.join(__dirname, 'src', '_helper-docs', name+'.md'), 'utf8')
	const content = marked(file)

	return new HtmlWebpackPlugin({
		template: path.join(__dirname, 'src', '_helper-docs', 'helperTemplate'),
		filename: path.join(outputPath, 'guides', name+'.html'),
		title: name.charAt(0).toUpperCase() + name.slice(1),
		chunks: ['guides'],
		content: content.html
	})
}

let buildConfig = widgetWebpack.getLegacyWidgetBuildConfig(options)

buildConfig.plugins.unshift(generateHelperPlugin('creator'))
buildConfig.plugins.unshift(generateHelperPlugin('player'))

module.exports = buildConfig

//module.exports = webpackConfig
