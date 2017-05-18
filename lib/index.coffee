# accepts value paired with an `output`,
# and uses the output to encode the value into bytes.
# can configure which "specifier" bytes it uses via options.
# can configure the `unstring` it uses for string replacement.
class Enbyte

  constructor: (options) ->

    # use @endeo/bytes by default
    @B = options?.bytes ? require '@endeo/bytes'

    # use a noop function by default
    ### istanbul ignore next ###
    @unstring = options?.unstring ? string: ->

    # Output
    # use an @endeo/output by default
    @Output = options?.output ? require '@endeo/output'


  output: (writer, target) -> @Output {writer, target}


  # include methods from separate files:

  encode : require './encode' # generic entry point for any type.
  object : require './object' # generic entry point for either object type.
  special: require './object-special' # has an "object spec"
  generic: require './object-generic'

  array : require './array'

  string: require './string'

  num  : require './num'     # generic entry point for all numbers

  int  : require './int'     # generic entry point for integer numbers
  int0 : require './int0'    # always 0 byte int
  int1 : require './int1'    # always 1 byte int
  int2 : require './int2'    # always 2 byte int
  int3 : require './int3'    # always 3 byte int
  int4 : require './int4'    # always 4 byte int
  int5 : require './int5'    # always 5 byte int
  int6 : require './int6'    # always 6 byte int
  int7 : require './int7'    # always 7 byte int
  int8 : require './int8'    # always 8 byte int

  float : require './float'  # generic entry point for float numbers
  float4: require './float4' # always 4 byte float
  float8: require './float8' # always 8 byte float

  bool: (value, output) -> output.marker if value then @B.TRUE else @B.FALSE


# export a builder function and the class
module.exports = (options) -> new Enbyte options
module.exports.Enbyte = Enbyte
