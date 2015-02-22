# Constants
PLUGINS = [
  'vips'
  'imagemagick'
]

# Helper
getPlugin = (_) ->
  for name in PLUGINS
    plugin = require "./#{name}"
    return plugin if plugin.isAvailable _
  libraries = for name in PLUGINS
    """#{name} (#{require("./#{name}").MINIMUM_VERSION})"""
  throw new Error "Please install one of the following libraries: #{libraries.join ', '}"


# Public API
module.exports = class DeepZoomImage
  constructor: (@source, @width, @height, @tileSize, @tileOverlap, @format) ->
    @levels = []
    @tileWidth = @tileSize
    @tileHeight = @tileSize
    @numLevels = Math.ceil(Math.log(Math.max(@width, @height)) / Math.LN2) + 1
    @_createLevels @tileSize, @tileSize, @numLevels

  @create: (_, source, destination, tileSize, tileOverlap, format) ->
    plugin = getPlugin _
    # NOTE: We want to pass all arguments to the plugin, but this is an async
    # Streamline method, so we use Streamline's special `apply_` to do that.
    # https://github.com/Sage/streamlinejs/blob/master/lib/compiler/builtins.md#function-functions
    args = [].slice.call arguments, 1           # Excludes _
    plugin.convert.apply_ _, null, args, 0      # Insert _ at position 0

  _createLevels: (tileWidth, tileHeight, numLevels) ->
    @numTiles = 0
    for index in [0...numLevels]
      size = @_getSize index
      width = size.x
      height = size.y
      numColumns = Math.ceil width / tileWidth
      numRows = Math.ceil height / tileHeight
      @numTiles += numColumns * numRows
      url = @_getLevelURL index
      level = {index, width, height, numColumns, numRows, url}
      @levels.push level

  _getTileURL: (level, column, row) ->
    levelPath = @levels[level].url
    "#{levelPath}/#{column}_#{row}.#{@format}"

  _getLevelURL: (level) ->
    basePath = @source.substring 0, @source.lastIndexOf '.'
    root = "#{basePath}_files"
    "#{root}/#{level}"

  _getScale: (level) ->
    maxLevel = @numLevels - 1
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
    <Image TileSize="#{@tileSize}" Overlap="#{@tileOverlap}" Format="#{@format}"
           xmlns="http://schemas.microsoft.com/deepzoom/2008">
         <Size Width="#{@width}" Height="#{@height}"/>
    </Image>
    """

  _getTileBounds: (level, column, row) ->
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

  getTile: (level, column, row) ->
    tile = @_getTileBounds level, column, row
    tile.url = @_getTileURL level, column, row
    tile
