# Enbyte's generic() method.
# used specifically for objects without a known "object spec".
module.exports = (object, keys, output) ->

  # tell them an oject is on the way (a generic one).
  output.marker @B.OBJECT

  # use the `keys` array already provided for us.
  # it's available because we used it earlier to determine
  # if the object was empty. it's not.
  for key in keys

    # the key is a string. this handles unstring'ing, too.
    @string key, output

    # the value can be anything.
    @encode object[key], output

  # avoid sending both next to each other. it's redundant.
  output.markerUnlessNextIs @B.SUB_TERMINATOR, @B.TERMINATOR
