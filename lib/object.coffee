# Enbyte's object() method.
# a generic entry point for either special objects or generic ones.
# NOTE:
#  zero content means empty array instead of B.EMPTY_OBJECT.
#  reasons:
#    * I suspect empty objects will be rare.
#    * we can use an empty object as the default and B.DEFAULT
#    * eliminates the complexity of specifying generic, special, empty object.
#    * adding it back is easy to do.
module.exports = (object, output) ->

  # `keys` are used for two things:
  #  1. check if object is empty
  #  2. if it is a generic object we can use the keys for iterating.
  keys = Object.keys object

  # check if it's an empty object.
  if keys.length < 1
    output.marker @B.OBJECT
    output.markerUnlessNextIs @B.SUB_TERMINATOR, @B.TERMINATOR

  # does it have an object spec?
  else if object.$ENDEO_SPECIAL? then @special object.$ENDEO_SPECIAL, object, output

  # it's a generic object, no spec. pass on the keys we already gathered.
  # TODO: move this to @enbyte.genericObject
  else @generic object, keys, output
