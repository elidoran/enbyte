### istanbul ignore next ###
isInt = Number.isInteger ? (n) -> isFinite(n) and Math.floor(n) is n

module.exports = (num, output) ->

  if isInt num then @int num, output else @float num, output


# export the helper function
module.exports.isInt = isInt
