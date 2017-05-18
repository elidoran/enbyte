# Enbyte's int1() method.
# always sends int using 1 byte.
module.exports = (num, output) ->

    if num >= 0

      output.marker @B.P1
      output.byte num - @int.max.b0

    else

      output.marker @B.N1
      output.byte Math.abs(num) - @int.max.b0
