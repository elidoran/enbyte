# Enbyte's array() method.
module.exports = (array, output) ->

  # NOTE: endeo.array() won't get here when it's empty. so we can:
  if array.length < 1 then return output.marker @B.EMPTY_ARRAY

  output.marker @B.ARRAY

  @encode element, output for element in array

  output.markerUnlessNextIs @B.SUB_TERMINATOR, @B.TERMINATOR
