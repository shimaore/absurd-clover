ccnq3 = window.ccnq3 ?= {}
ccnq3.monitor = (hour,timezone,selector,field_name,view_name) ->
  console.log "monitor #{hour} #{timezone} #{selector} #{field_name} #{view_name}"
  $(selector).html "<table><caption>#{field_name} data: updating</caption></table>"
  if hour?
    hour = new timezoneJS.Date hour, timezone
  else
    hour = new timezoneJS.Date timezone
  hour = hour.toString('yyyy-MM-dd HH')

  # DataTables
  start = escape JSON.stringify [hour]
  end   = escape JSON.stringify [hour,{}]

  columns = [
    field_name                # 0
    'Inbound Attempts'        # 1
    'Inbound Attempts (cps)'
    'Inbound Success'
    'Inbound Success (cps)'
    'Inbound CSR'
    'Inbound Short (%)'
    'Inbound Minutes'
    'Inbound ACD (s)'
    'Outbound Attempts'       # 9
    'Outbound Attempts (cps)'
    'Outbound Success'
    'Outbound Success (cps)'
    'Outbound CSR'
    'Outbound Short (%)'
    'Outbound Minutes'
    'Outbound ACD (s)'
  ]
  $.getJSON "_view/#{view_name}?group_level=3&start_key=#{start}&end_key=#{end}&stale=update_after", (json) ->
    set = {}
    for row in json.rows
      [hour,direction,r0] = row.key
      rec = set[r0] ? []

      rec[0] = r0 ? ''
      for i in [0..columns.length]
        rec[i] ?= ''
      b = null
      if direction is 'ingress'
        b = 1
      if direction is 'egress'
        b = 9
      if b?
        rec[b++] = row.value.attempts
        rec[b++] = (row.value.attempts/3600).toFixed(3)
        rec[b++] = row.value.success
        rec[b++] = (row.value.success/3600).toFixed(3)
        if row.value.attempts > 0
          rec[b++] = (100*row.value.success/row.value.attempts).toFixed(1)
          rec[b++] = (100*row.value.short/row.value.attempts).toFixed(1)
        else
          rec[b++] = ''
          rec[b++] = ''
        rec[b++] = (row.value.duration/60).toFixed(1)
        if row.value.success > 0
          rec[b++] = (row.value.duration/row.value.success).toFixed(1)
        else
          rec[b++] = ''
      set[r0] = rec

    data = []
    for k,v of set
      data.push v


    t = $(selector).children('table')

    t.children('caption').html "#{field_name}: #{hour} #{timezone}"

    t.dataTable
      aaData: data
      aoColumns: columns.map (v) -> { sTitle: v, sClass: 'right' }

ccnq3.account_monitor = (hour,timezone) =>
  ccnq3.monitor hour, timezone, '#account', 'Account', 'account_monitor'
ccnq3.profile_monitor = (hour,timezone) =>
  ccnq3.monitor hour, timezone, '#profile', 'Profile', 'profile_monitor'
