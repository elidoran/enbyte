POW_SIX = Math.pow 2, 48

# Enbyte's int7() method.
# writes an int with 7 bytes.
module.exports = (num, output) ->

  # these test capacity and increment index
  # output.byte value / POW_SIX
  # output.num value, 6

  # instead, ensure we have enough byte space,
  # then do the writes directly,
  # then increment index.
  output.prepare 8

  if num >= 0

    output.marker @B.P7
    value = num

  else

    output.marker @B.N7
    value = Math.abs num

  output.buf.writeUInt8 value / POW_SIX, output.index, true
  output.buf.writeUIntBE value, output.index + 1, 6, true
  output.increment 7
