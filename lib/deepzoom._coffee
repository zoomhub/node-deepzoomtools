fs = require 'fs'
im = require('gm').subClass {imageMagick: true}
mkdirp = require 'mkdirp'
path = require 'path'
ProgressBar = require 'progress'


# Constants
DEFAULT_TILE_SIZE = 254
DEFAULT_TILE_OVERLAP = 1
DEFAULT_FORMAT = 'jpg'
FORMATS =
  JPEG: 'jpg'
  PNG: 'png'


module.exports = class DeepZoomImage
  constructor: (@source, @width, @height, @tileSize, @tileOverlap, @format) ->
    @levels = []
    @tileWidth = @tileSize
    @tileHeight = @tileSize
    @numLevels = Math.ceil(Math.log(Math.max(@width, @height)) / Math.LN2) + 1
    @_createLevels @tileSize, @tileSize, @numLevels

  @create: (_, source, destination, tileSize, tileOverlap, format) ->
    tileSize ?= DEFAULT_TILE_SIZE
    tileOverlap ?= DEFAULT_TILE_OVERLAP
    image = im source
    {width, height} = image.size _
    format ?= FORMATS[image.format _]

    descriptor = new DeepZoomImage source, width, height, DEFAULT_TILE_SIZE,
      DEFAULT_TILE_OVERLAP, format

    # Tiles
    for index in [descriptor.numLevels - 1..0]
      level = descriptor.levels[index]
      levelImage = im(source).resize level.width, level.height, '!'
      for column in [0...level.numColumns]
        for row in [0...level.numRows]
          url = descriptor.getTileURL index, column, row
          bounds = descriptor.getTileBounds index, column, row
          levelImage.crop bounds.width, bounds.height, bounds.x, bounds.y
          outputPath = path.dirname url
          mkdirp outputPath, _
          levelImage.write url, _

    # Manifest
    descriptor.writeManifest _

  _createLevels: (tileWidth, tileHeight, numLevels) ->
    @numTiles = 0
    for index in [0...numLevels]
      size = @_getSize index
      width = size.x
      height = size.y
      numColumns = Math.ceil width / tileWidth
      numRows = Math.ceil height / tileHeight
      @numTiles += numColumns * numRows
      level = {index, width, height, numColumns, numRows}
      @levels.push level

  getTileURL: (level, column, row) ->
    basePath = @source.substring 0, @source.lastIndexOf '.'
    root = "#{basePath}_files"
    "#{root}/#{level}/#{column}_#{row}.#{@format}"

  _getScale: (level) ->
    maxLevel = @numLevels - 1
    # 1 / (1 << maxLevel - level)
    Math.pow 0.5, maxLevel - level

  _getSize: (level) ->
    size = {}
    scale = @_getScale level
    size.x = Math.ceil @width * scale
    size.y = Math.ceil @height * scale
    size

  getManifest: ->
    """
    <?xml version="1.0" encoding="utf-8"?>
    <Image TileSize="#{@tileSize}" Overlap="#{@tileOverlap}" Format="#{@format}" ServerFormat="Default" xmlns="http://schemas.microsoft.com/deepzoom/2009">
         <Size Width="#{@width}" Height="#{@height}"/>
    </Image>

    """

  getManifestPath: ->
    root = path.dirname @source
    filename = path.basename @source, path.extname @source
    path.join root, "#{filename}.dzi"

  writeManifest: (_) ->
    filename = @getManifestPath()
    manifest = @getManifest()
    fs.writeFile filename, manifest, _

  getTileBounds: (level, column, row) ->
    bounds = {}
    offsetX = if column is 0 then 0 else @tileOverlap
    offsetY = if row is 0 then 0 else @tileOverlap
    bounds.x = (column * @tileWidth) - offsetX
    bounds.y = (row * @tileHeight) - offsetY

    l = @levels[level]
    width = @tileWidth + ((if column is 0 then 1 else 2) * @tileOverlap)
    height = @tileHeight + ((if row is 0 then 1 else 2) * @tileOverlap)
    bounds.width = Math.min width, l.width - bounds.x
    bounds.height = Math.min height, l.height - bounds.y
    bounds
