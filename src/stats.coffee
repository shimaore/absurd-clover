ccnq3 = window.ccnq3 ?= {}
ccnq3.graph_hourly = (timezone) ->
  console.log "graph_hourly #{timezone}"

  timeout = 120
  days_back = 180

  second = 1000
  hour = 3600*second
  day = 24*hour

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
      min: now - 1*day
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

  $('#flot').text "Please wait, retrieving data, timing out after #{timeout} seconds."
  $.ajax
    type: 'GET'
    accepts: 'application/json'
    dataType: 'json'
    url: '_view/account_monitor'
    timeout: timeout*1000
    data:
      group_level: 2
      stale: 'update_after'
      startkey: JSON.stringify ["#{(new Date(now-days_back*day)).toISOString()[0..9]}"]
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
