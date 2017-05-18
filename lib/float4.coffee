# Enbyte's float4() method.
module.exports = (num, output) ->

  output.marker @B.FLOAT4
  output.float4 num
