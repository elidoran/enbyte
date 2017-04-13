class Enbyte

  constructor: (options) ->

    @delim = options?.delim ? 0xFF

  encode: (object, writer, target) ->

  object: (object, writer, target) ->
  array: (object, writer, target) ->
  string: (object, writer, target) ->


# export a function which creates an instance
module.exports = (options) -> new Enbyte options

# export the class as a sub property on the function
module.exports.Enbyte = Enbyte
