# Enbyte's float() method.
module.exports = (num, output) ->

  # try to create a float buffer
  buffer = output.allocate 4
  buffer.writeFloatBE num, 0, true

  if num is buffer.readFloatBE 0, true
    output.marker @B.FLOAT4
    output.buffer buffer

  else
    output.marker @B.FLOAT8
    output.float8 num
