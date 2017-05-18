assert = require 'assert'

B = require '@endeo/bytes'
buildOutput = require '@endeo/output'
buildEnbyte = require '../../lib/index.coffee'

build = buildEnbyte.bind null, bytes:B, unstring:{}

bytes4 = (marker, float) ->
  buffer = Buffer.alloc 5
  buffer[0] = marker
  buffer.writeFloatBE float, 1, true
  buffer

bytes8 = (marker, float) ->
  buffer = Buffer.alloc 9
  buffer[0] = marker
  buffer.writeDoubleBE float, 1, true
  buffer

tests = [

  [  '0.0',  0.0, bytes4 B.FLOAT4,    0 ]
  [ '-0.0', -0.0, bytes4 B.FLOAT4, -0.0 ]
  [  '1.0',  1.0, bytes4 B.FLOAT4,  1.0 ]
  [ '-1.0', -1.0, bytes4 B.FLOAT4, -1.0 ]

  [  '1.25',  1.25, bytes4 B.FLOAT4,  1.25 ]
  [ '-1.25', -1.25, bytes4 B.FLOAT4, -1.25 ]

  [  '123.456',  123.456, bytes8 B.FLOAT8,  123.456 ]
  [ '-123.456', -123.456, bytes8 B.FLOAT8, -123.456 ]

  # 7 byte numbers aren't shifted to allow for more values in the range
  # because ECMAScript only supports up to 53 bits.
  # [ 282578800148837,  bytes B.P7, 1, 1, 1, 1, 1, 1, 0x65 ]
  # [ -282578800148837, bytes B.N7, 1, 1, 1, 1, 1, 1, 0x65 ]
  #
  # [ 9007199254740992,  bytes B.P7, 0x20, 0, 0, 0, 0, 0, 0 ]
  # [ -9007199254740992, bytes B.N7, 0x20, 0, 0, 0, 0, 0, 0 ]

]

describe 'test enbyte floats', ->

  for test in tests

    do (test) -> it 'should encode ' + test[0], ->

      enbyte = build()
      output = buildOutput()
      enbyte.float test[1], output
      result = output.complete()
      buffer = result?.buffer

      assert result, 'should provide a result'
      assert.equal Buffer.isBuffer(buffer), true, 'result should have a Buffer'
      assert.equal buffer.length, test[2].length
      assert.deepEqual buffer, test[2]
