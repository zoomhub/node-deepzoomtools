DeepZoomImage = require '../lib/deepzoom._coffee'
path = require 'path'

SOURCE = path.join __dirname, '..', 'images', '1.jpg'
DESTINATION = path.join __dirname, '..', 'images', '1.dzi'


DEFAULT_TILE_SIZE = 254
DEFAULT_TILE_OVERLAP = 1
DEFAULT_FORMAT = 'jpg'

DeepZoomImage.create _, SOURCE, DESTINATION, DEFAULT_TILE_SIZE,
  DEFAULT_TILE_OVERLAP, DEFAULT_FORMAT
