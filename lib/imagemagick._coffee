DeepZoomImage = require './index'
defaults = require './defaults'
fs = require 'fs'
im = require('gm').subClass {imageMagick: true}
mkdirp = require 'mkdirp'
path = require 'path'
util = require './util'


# Constants
FORMATS =
  JPEG: 'jpg'
  PNG: 'png'

VERSION_REGEX = /ImageMagick (\d+\.\d+\.\d+)/


# Public API
exports.MINIMUM_VERSION = '^6.6.9'

exports.isAvailable = (_) ->
  raw = util.getVersion 'convert --version', _
  version = raw?.match(VERSION_REGEX)?[1]
  util.satisfiesVersion version, exports.MINIMUM_VERSION

exports.convert = (_, source, destination, tileSize=defaults.TILE_SIZE,
                  tileOverlap=defaults.TILE_OVERLAP, format) ->
  image = im source
  {width, height} = image.size _
  format ?= FORMATS[image.format _] ? defaults.FORMAT

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
