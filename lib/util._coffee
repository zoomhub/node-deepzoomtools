exec = require('child_process').exec
semver = require 'semver'


# Public API
exports.getVersion = (command, _) ->
  try
    [stdout, stderr] = exec command, [_]
  catch error
    return null
  if stderr?.length > 0
    return null
  stdout

exports.satisfiesVersion = (version, minimumVersion) ->
  if not version?
    return false
  semver.satisfies version, minimumVersion
