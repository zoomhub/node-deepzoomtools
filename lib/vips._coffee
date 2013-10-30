exec = require('child_process').exec
path = require 'path'


# Constants
DEFAULT_TILE_SIZE = 254
DEFAULT_TILE_OVERLAP = 1
DEFAULT_FORMAT = 'jpg'
FORMATS =
  JPEG: 'jpg'
  PNG: 'png'


module.exports = (_, source, destination, tileSize=DEFAULT_TILE_SIZE,
                  tileOverlap=DEFAULT_TILE_OVERLAP, format=DEFAULT_FORMAT) ->
  outputPath = getOutputPath destination
  command = "vips dzsave #{source} #{outputPath} --overlap=#{tileOverlap}
 --tile-width=#{tileSize} --tile-height=#{tileSize} --suffix=.#{format}"
  exec command, _


getOutputPath = (dzi) ->
  root = path.dirname(destination)
  base = path.basename destination, path.extname destination
  outputPath = path.join root, base
