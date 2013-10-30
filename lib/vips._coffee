defaults = require './defaults'
exec = require('child_process').exec
path = require 'path'


module.exports = (_, source, destination, tileSize=defaults.TILE_SIZE,
                  tileOverlap=defaults.TILE_OVERLAP, format=defaults.FORMAT) ->
  outputPath = getOutputPath destination
  command = "vips dzsave #{source} #{outputPath} --overlap=#{tileOverlap}
 --tile-width=#{tileSize} --tile-height=#{tileSize} --suffix=.#{format}"
  exec command, _


getOutputPath = (destination) ->
  root = path.dirname(destination)
  base = path.basename destination, path.extname destination
  outputPath = path.join root, base
