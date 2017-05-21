# used to determine if a value equals its default
# so we can send B.DEFAULT.
equal = require 'deep-eql'

# Enbyte's special() method for encoding objects with
# a known "object spec".
module.exports = exports = (spec, object, output) ->

  # always prefix with SPECIAL marker.
  # endeo will handle not using it as the first byte via output.consumeMarkerIf()
  output.marker @B.SPECIAL

  # if id fits into a single byte (tiny int: 0 - 100)
  if spec.id < @B.SPECIAL then output.marker spec.id

  # send it to int()
  else
    output.markerUnlessPreviousWas @B.SPECIAL, @B.SPECIAL
    # problem. if endeo consumes B.SPECIAL above for abbreviated indicator,
    # then outputting an extended length ID won't work.
    # an extended ID *must* be preceded by B.SPECIAL.
    # so, for now, say output B.SPECIAL unless we already did.
    # this basically makes it:
    #   send it unless endeo said not to,
    #   but send it anyway if we have an extended ID,
    #   unless we already did actually send it cuz endeo didn't say not to.
    # :-/
    # yes, I *could* have it always output B.SPECIAL.
    # I started with the whole "indicator byte" idea, from the beginning,
    # which differs from "specifier byte".
    @int spec.id, output

  # TODO:
  # check how slow this could be.
  # if equal value, spec.default then output.marker @B.DEFAULT
  # else # iterate thru spec's key info

  # second, output each key's info (value). return the error if it occurs.
  # NOTE: uses sub-function cuz it may recurse on itself.
  result = exports.iterate this, spec.array, object, output

  if result?.error then return result

  # third, say we're all done with this object.
  # avoid sending both next to each other because it's redundant.
  output.markerUnlessNextIs @B.SUB_TERMINATOR, @B.TERMINATOR


exports.iterate = (enbyte, array, object, output) ->

  for keyInfo in array

    # A. get the value from the object so we can compare it and *maybe* encode it.
    value = object[keyInfo.key]

    # B. if the value is the default then say so and move on.
    if equal value, keyInfo.default
      output.marker enbyte.B.DEFAULT
      continue

    # C. chose a method of encoding the value.
    result =

      # C1. if it has a specific `encode` to use then we'll use that.
      if keyInfo.encode? then keyInfo.encode enbyte, value, output

      # C2. if keyInfo knows this object's properties already then iterate them.
      #     (means it was part of the "object spec" analysis)
      else if keyInfo.array? then @iterate enbyte, keyInfo.array, value, output

      # C3. if the value is an object with an "object spec"
      else if value.$ENDEO_SPECIAL?
        enbyte.special value.$ENDEO_SPECIAL, value, output

      # C4. it's an unknown type, so, use general encode().
      else enbyte.encode value, output

    # D. if there was an error then return that now
    if result?.error then return result
