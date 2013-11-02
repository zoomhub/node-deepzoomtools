assert = require 'assert'
DeepZoomImage = require '../lib'
path = require 'path'


# Test overlaps
source = '1.dzi'
width = 4000
height = 3000
tileSize = 254
tileOverlap = 1
format = 'jpg'
descriptor = new DeepZoomImage source, width, height, tileSize, tileOverlap,
                               format

maxLevel = descriptor.numLevels - 1
for index in [maxLevel..0]
  level = descriptor.levels[index]
  for column in [1...level.numColumns]
    previous = descriptor.getTile index, (column - 1), row
    current = descriptor.getTile index, column, row
    previousRight = previous.x + previous.width
    currentLeft = current.x
    actual = previousRight - currentLeft
    expected = 2 * descriptor.tileOverlap
    assert.equal actual, expected,
      "Check overlap for column #{column}. Actual: #{actual}, expected: #{expected}."
    for row in [1...level.numRows]
      previous = descriptor.getTile index, column, (row - 1)
      current = descriptor.getTile index, column, row
      previousBottom = previous.y + previous.height
      currentTop = current.y
      actual = previousBottom - currentTop
      expected = 2 * descriptor.tileOverlap
      assert.equal actual, expected,
        "Check overlap for row #{row}. Actual: #{actual}, expected: #{expected}"


# Create pyramid
ID = Math.floor Math.random() * 1000
SOURCE = path.join __dirname, '..', 'images', '1.jpg'
DESTINATION = path.join __dirname, '..', 'images', "#{ID}.dzi"


DEFAULT_TILE_SIZE = 254
DEFAULT_TILE_OVERLAP = 1
DEFAULT_FORMAT = 'jpg'

DeepZoomImage.create _, SOURCE, DESTINATION, DEFAULT_TILE_SIZE,
  DEFAULT_TILE_OVERLAP, DEFAULT_FORMAT
