# Enbyte's int6() method.
# always sends int using 6 bytes.
module.exports = (num, output) ->

  if num >= 0

    output.marker @B.P6
    output.int num - @int.max.b5, 6

  else

    output.marker @B.N6
    output.int Math.abs(num) - @int.max.b5, 6
