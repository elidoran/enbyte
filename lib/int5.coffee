# Enbyte's int5() method.
# always sends int using 5 bytes.
module.exports = (num, output) ->

    if num >= 0

      output.marker @B.P5
      output.int num - @int.max.b4, 5

    else

      output.marker @B.N5
      output.int Math.abs(num) - @int.max.b4, 5
