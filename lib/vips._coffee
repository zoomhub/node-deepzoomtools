defaults = require './defaults'
exec = require('child_process').exec
fs = require 'fs'
path = require 'path'
util = require './util'


# Helper
getOutputPath = (destination) ->
  root = path.dirname(destination)
  base = path.basename destination, path.extname destination
  outputPath = path.join root, base

existsFile = (filePath, callback) ->
  fs.exists filePath, (exists) ->
    callback null, exists

# Public API
exports.MINIMUM_VERSION = '^7.32.1'

exports.isAvailable = (_) ->
  raw = util.getVersion 'vips --version', _
  version = raw?.split('-')?[1]
  util.satisfiesVersion version, exports.MINIMUM_VERSION

exports.convert = (_, source, destination, tileSize=defaults.TILE_SIZE,
                  tileOverlap=defaults.TILE_OVERLAP, format=defaults.FORMAT) ->
  outputPath = getOutputPath destination
  tileDirectory = "#{outputPath}_files"
  if existsFile tileDirectory, _
    error = new Error "Directory #{tileDirectory} already exists"
    error.code = 1
    throw error
  command = "vips dzsave #{source} #{outputPath}
 --overlap=#{tileOverlap}
 --tile-size=#{tileSize}
 --suffix=.#{format}"
  exec command, _
