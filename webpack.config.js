const path = require('path')

// load the reusable legacy webpack config from materia-widget-dev
let webpackConfig = require('materia-widget-development-kit/webpack-widget').getLegacyWidgetBuildConfig()

webpackConfig.entry['assets/lib/draw.js'] = [path.join(__dirname, 'src', 'assets', 'lib', 'draw.coffee')]

module.exports = webpackConfig
