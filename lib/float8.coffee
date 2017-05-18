# Enbyte's float8() method.
module.exports = (num, output) ->

  output.marker @B.FLOAT8
  output.float8 num
