console.log "Initializing."
ccnq3 = window.ccnq3 ?= {}
timezoneJS.timezone.zoneFileBasePath = 'tz'
timezoneJS.timezone.init()
timezone = 'US/Central' # FIXME this should be provided somewhere else!!
$(document).ready =>
  console.log "Starting."
  graph_hourly = =>
    ccnq3.graph_hourly timezone
  setInterval graph_hourly, 5*60*1000
  do graph_hourly
  console.log "Started."
console.log "Initialized."
