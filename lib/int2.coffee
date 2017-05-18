# Enbyte's int2() method.
# always sends int using 2 bytes.
module.exports = (num, output) ->

    if num >= 0

      output.marker @B.P2
      output.int num - @int.max.b1, 2

    else

      output.marker @B.N2
      output.int Math.abs(num) - @int.max.b1, 2
