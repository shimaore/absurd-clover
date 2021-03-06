p_fun = (f) -> '('+f+')'

reduce_monitor = p_fun (key,values,rereduce) ->
  result =
    attempts: 0
    success: 0
    duration: 0
  if not rereduce
    for v in values
      result.attempts += 1
      result.success += 1 if v > 0
      result.duration += v
      result.short += 1 if v > 0 and v < 6
  else
    for v in values
      result.attempts += v.attempts
      result.success += v.success
      result.duration += v.duration
      result.short += v.short
  return result

pkg = require './package.json'
ddoc =
  _id: "_design/#{pkg.name}"
  filters: {}
  language: 'javascript'
  views:
    account_monitor:
      map: p_fun (doc) ->
        return unless doc.variables?
        account = doc.variables.ccnq_account
        direction = doc.variables.ccnq_direction
        hour = doc.variables.start_stamp.substr 0, 13
        emit [hour,direction,account], parseInt doc.variables.billsec ? 0
        return
      reduce: reduce_monitor

    profile_monitor:
      map: p_fun (doc) ->
        return unless doc.variables?
        profile = doc.variables.ccnq_profile
        direction = doc.variables.ccnq_direction
        hour = doc.variables.start_stamp.substr 0, 13
        emit [hour,direction,profile], parseInt doc.variables.billsec ? 0
        return
      reduce: reduce_monitor

couchapp = require 'couchapp'
path = require 'path'
couchapp.loadAttachments(ddoc, path.join(__dirname, 'assets'));
couchapp.loadAttachments(ddoc, path.join(__dirname, 'local'));
couchapp.loadAttachments(ddoc, path.join(__dirname, 'src'));
module.exports = ddoc
