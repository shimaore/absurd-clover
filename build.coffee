fs = require 'fs'
teacup = require 'teacup'
html = teacup.render require './src/index.coffee'
fs.writeFileSync './local/index.html', html
