POW_SIX = Math.pow 2, 48

# Enbyte's int8() method.
# writes an int with 8 bytes.
module.exports = (num, output) ->

  # instead, ensure we have enough byte space,
  # and then do the writes directly.
  output.prepare 9

  if num >= 0

    output.marker @B.P8
    value = num

  else

    output.marker @B.N8
    value = Math.abs num

  output.buf.writeInt16BE value / POW_SIX, output.index, true
  output.buf.writeUIntBE value, output.index + 2, 6, true
  output.increment 8
