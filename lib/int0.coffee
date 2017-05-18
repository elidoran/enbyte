# Enbyte's int0() method.
# always sends int using only 1 "special" byte
module.exports = (num, output) ->

  # NOTE:
  # if value is greater than @B.MAX_NEG then it will be seen as a
  # different value and mess everything up.
  # so, don't use this for values which are too large.
  
  output.marker if num >= 0 then num else Math.abs(num) + @B.MAX_POS
