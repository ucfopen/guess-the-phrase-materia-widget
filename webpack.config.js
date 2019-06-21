const fs = require('fs')
const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const marked = require('meta-marked')
const widgetWebpack = require('materia-widget-development-kit/webpack-widget')
const ModernizrWebpackPlugin = require('modernizr-webpack-plugin');
const srcPath = path.join(__dirname, 'src') + path.sep

const copy = widgetWebpack.getDefaultCopyList()

const entries = widgetWebpack.getDefaultEntries()

entries['player.js'] = [
	srcPath+'draw.coffee',
	srcPath+'player.coffee'
]
entries['assets/lib/draw.js'] = [srcPath+'draw.coffee']
entries['guides/guideStyles.css'] = [srcPath+'_helper-docs/guideStyles.scss']
entries['assets/lib/angular-hammer.min.js'] = [srcPath+'angular-hammer.js']

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
	{
		from: path.join(__dirname, 'node_modules', 'createjs', 'builds', 'createjs-2013.12.12.min.js'),
		to: path.join(__dirname, 'build', 'assets', 'lib', 'createjs.js')
	}
])

const options = {
	copyList: customCopy,
	entries: entries
}

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
