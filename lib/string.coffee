# Enbyte's string() method.
# NOTE: uses `unstring()` for replacements.
module.exports = (string, output) ->

  # if the string is empty then we can send that and be done.
  if string.length < 1 then return output.marker @B.EMPTY_STRING

  # can we "unstring" the the string
  result = @unstring.string string

  # if the unstring already knew it then we can avoid sending it.
  if result?.known is true

    # # it's an "already known" string

    # 1. tell them
    output.marker @B.GET_STRING

    # 2. tell them the id
    @int result.id, output


  # if the unstring learned it now then we can't avoid sending it,
  # but, we can say we've learned it to avoid it next time.
  else if result?.known is false

    # # if it's a new string to learn

    # 1a. tell them
    output.marker @B.NEW_STRING

    # 1b. tell them the id
    @int result.id, output # TODO: do we tell them the id? hmm.

    # # then send them the string

    # 2a. send the length ahead
    length = Buffer.byteLength string

    # NOTE:
    # nah, we don't know int output size, and output.string is good.
    # output.prepare 8 + length

    @int length, output

    # 2b. finally, send the string
    output.string string, length


  else # otherwise write the string

    # 1. tell them a string is coming
    # NOTE: endeo.string() writes B.STRING, so, don't repeat it.
    output.markerUnlessPreviousWas @B.STRING, @B.STRING

    # 2. send the length ahead
    length = Buffer.byteLength string

    # NOTE:
    # nah, we don't know int output size, and output.string is smart.
    # output.prepare 8 + length

    @int length, output

    # 3. finally, send the string
    output.string string, length


  # NOTE:
  #  unlike other types, we don't output a SUB_TERMINATOR after a string
  #  because it either has only two bytes or uses headers to specify its length.
  return
