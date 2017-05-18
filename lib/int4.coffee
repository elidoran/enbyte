# Enbyte's int4() method.
# always sends int using 4 bytes.
module.exports = (num, output) ->

  if num >= 0

    output.marker @B.P4
    output.int num - @int.max.b3, 4

  else

    output.marker @B.N4
    output.int Math.abs(num) - @int.max.b3, 4
