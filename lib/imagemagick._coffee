DeepZoomImage = require './deepzoom'
fs = require 'fs'
im = require('gm').subClass {imageMagick: true}
mkdirp = require 'mkdirp'
path = require 'path'


# Constants
DEFAULT_TILE_SIZE = 254
DEFAULT_TILE_OVERLAP = 1
DEFAULT_FORMAT = 'jpg'
FORMATS =
  JPEG: 'jpg'
  PNG: 'png'


module.exports = (_, source, destination, tileSize=DEFAULT_TILE_SIZE,
                  tileOverlap=DEFAULT_TILE_OVERLAP, format) ->
  image = im source
  {width, height} = image.size _
  format ?= FORMATS[image.format _] ? DEFAULT_FORMAT

  # Descriptor
  descriptor = new DeepZoomImage destination, width, height, tileSize,
                                 tileOverlap, format

  # Tiles
  maxLevel = descriptor.numLevels - 1
  for index in [maxLevel..0]
    level = descriptor.levels[index]
    mkdirp level.url, _
    for column in [0...level.numColumns]
      for row in [0...level.numRows]
        tile = descriptor.getTile index, column, row
        options = '!' # force resize
        tileImage = im(source).resize(level.width, level.height, options)
                         .crop tile.width, tile.height, tile.x, tile.y
        tileImage.write tile.url, _

  # Manifest
  manifest = descriptor.getManifest() + '\n'
  fs.writeFile destination, manifest, _
