{doctype,html,head,meta,title,link,script,body,div,address} = require 'teacup'
pkg = require '../package.json'

module.exports = ->
  doctype 5
  html ->
    head ->
      meta charset: 'utf-8'
      title 'Statistics'
      link rel:'stylesheet', href:'index.css', type:'text/css'
      script type:'text/javascript', src:'jquery.min.js'
      script type:'text/javascript', src:'date.js'
      # Flot:
      script type:'text/javascript', src:'jquery.flot.js'
      script type:'text/javascript', src:'jquery.flot.time.js'
      script type:'text/javascript', src:'jquery.flot.navigate.js'
      script type:'text/javascript', src:'jquery.flot.tooltip.js'
      # Datatables:
      script type:'text/javascript', src:'jquery.dataTables.min.js'
      link rel:'stylesheet', href:'jquery.dataTables.min.css', type:'text/css'
      # and our stuff:
      script type:'text/javascript', src:'table.js'
      script type:'text/javascript', src:'stats.js'
      script type:'text/javascript', src:'start.js'

    body ->
      div id:"main", ->
        div id:"flot"
        div id:"account"
        div id:"profile"
      address ->
        "This is #{pkg.name} #{pkg.version}."
