ccnq3 = window.ccnq3 ?= {}
ccnq3.graph_hourly = (timezone) ->
  console.log "graph_hourly #{timezone}"

  # Flot
  now = Date.now()
  options =
    series:
      lines:
        show: true
      points:
        show: false
      bars:
        show: false
    xaxis:
      mode: 'time'
      timezone: timezone
      timeformat: "%Y-%m-%d %H"
      minTickSize: [1,"hour"]
      min: now - 24*3600*1000
      max: now
    yaxis:
      min: 0
    yaxes: [
      { }
      { max: 100 }
    ]
    grid:
      hoverable: true
      clickable: true
    zoom:
      interactive: true
    pan:
      interactive: true
    tooltip: true

  data = []
  data[0] =
    data: []
    yaxis: 1
    label: 'Inbound Attempts (cps)'
  data[1] =
    data: []
    yaxis: 1
    label: 'Inbound Success (cps)'
  data[2] =
    data: []
    yaxis: 1
    label: 'Outbound Attempts (cps)'
  data[3] =
    data: []
    yaxis: 1
    label: 'Outbound Success (cps)'
  ###
  data[4] =
    data: []
    lines:
      show: false
    points:
      show: true
    yaxis: 2
    label: 'Inbound CSR (%)'
  data[5] =
    data: []
    lines:
      show: false
    points:
      show: true
    yaxis: 2
    label: 'Outbound CSR (%)'
  ###

  timeout = 120
  $('#flot').text "Please wait, retrieving data, timing out after #{timeout} seconds."
  $.ajax
    type: 'GET'
    accepts: 'application/json'
    dataType: 'json'
    url: '_view/account_monitor'
    timeout: timeout*1000
    startkey: JSON.stringify ["#{(new Date(now-366*24*3600*1000)).toISOString()[0..9]}"]
    data:
      group_level: 2
      stale: 'update_after'
  .fail (j,text,error) ->
    $('#flot').text "The query failed, sorry. Status: #{text}. Error: #{error}. (Please report this problem.)"
  .done (json) ->
    for row in json.rows
      [hour,direction] = row.key
      [yr,mo,dy,hr] = hour.split /[^\d]/
      hour = new timezoneJS.Date yr, mo-1, dy, hr, timezone
      if direction is 'ingress'
        data[0].data.push [hour,row.value.attempts/3600]
        data[1].data.push [hour,row.value.success/3600]
        ## data[4].data.push [hour,100*row.value.success/row.value.attempts] if row.value.attempts > 0
      if direction is 'egress'
        data[2].data.push [hour,row.value.attempts/3600]
        data[3].data.push [hour,row.value.success/3600]
        ## data[5].data.push [hour,100*row.value.success/row.value.attempts] if row.value.attempts > 0

    $('#flot').empty()
    $.plot '#flot', data, options
    $('#flot').bind 'plotclick', (event,pos,item) ->
      ccnq3.account_monitor? pos.x, timezone
      ccnq3.profile_monitor? pos.x, timezone
