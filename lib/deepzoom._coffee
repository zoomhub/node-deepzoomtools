exec = require('child_process').exec
path = require 'path'

bin = path.join __dirname, '..', 'bin', 'deepzoom'

exports.create = (source, _) ->
	try
		exec "#{bin} #{source}", _
	catch error
		throw new Error "Failed to convert image: #{error}"
