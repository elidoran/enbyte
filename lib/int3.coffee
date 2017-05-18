# Enbyte's int3() method.
# always sends int using 3 bytes.
module.exports = (num, output) ->

    if num >= 0

      output.marker @B.P3
      output.int num - @int.max.b2, 3

    else

      output.marker @B.N3
      output.int Math.abs(num) - @int.max.b2, 3
