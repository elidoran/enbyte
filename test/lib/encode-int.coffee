assert      = require 'assert'
B           = require '@endeo/bytes'
buildEnbyte = require '../../lib/index.coffee'
buildOutput = require '@endeo/output'
encodeTest  = require '../helpers/encode-tester.coffee'

bytes = ->
  args = new Array arguments.length
  args[i] = arguments[i] for i in [0 ... arguments.length]
  Buffer.from args

tests = [

  [ 0, bytes 0 ]
  [  1, bytes 1 ]
  [ -1, bytes 101 ]

  [  100, bytes 100 ]
  [ -100, bytes 200 ]

  [  101, bytes B.P1, 0 ]
  [ -101, bytes B.N1, 0 ]

  [  356, bytes B.P1, 255 ]
  [ -356, bytes B.N1, 255 ]

  [  357, bytes B.P2, 0, 0 ]
  [ -357, bytes B.N2, 0, 0 ]

  [  65892, bytes B.P2, 255, 255 ]
  [ -65892, bytes B.N2, 255, 255 ]

  [  65893, bytes B.P3, 0, 0, 0 ]
  [ -65893, bytes B.N3, 0, 0, 0 ]

  [  16843108, bytes B.P3, 255, 255, 255 ]
  [ -16843108, bytes B.N3, 255, 255, 255 ]

  [  16843109, bytes B.P4, 0, 0, 0, 0 ]
  [ -16843109, bytes B.N4, 0, 0, 0, 0 ]

  [  4311810404, bytes B.P4, 255, 255, 255, 255 ]
  [ -4311810404, bytes B.N4, 255, 255, 255, 255 ]

  [  4311810405, bytes B.P5, 0, 0, 0, 0, 0 ]
  [ -4311810405, bytes B.N5, 0, 0, 0, 0, 0 ]

  [  1103823438180, bytes B.P5, 255, 255, 255, 255, 255 ]
  [ -1103823438180, bytes B.N5, 255, 255, 255, 255, 255 ]

  [  1103823438181, bytes B.P6, 0, 0, 0, 0, 0, 0 ]
  [ -1103823438181, bytes B.N6, 0, 0, 0, 0, 0, 0 ]

  [  282578800148836, bytes B.P6, 255, 255, 255, 255, 255, 255 ]
  [ -282578800148836, bytes B.N6, 255, 255, 255, 255, 255, 255 ]

  # 7 byte numbers aren't shifted to allow for more values in the range
  # because ECMAScript only supports up to 53 bits.
  [  282578800148837, bytes B.P7, 1, 1, 1, 1, 1, 1, 0x65 ]
  [ -282578800148837, bytes B.N7, 1, 1, 1, 1, 1, 1, 0x65 ]

  [  9007199254740992, bytes B.P7, 0x20, 0, 0, 0, 0, 0, 0 ]
  [ -9007199254740992, bytes B.N7, 0x20, 0, 0, 0, 0, 0, 0 ]

]

describe 'test enbyte ints', ->

  for test in tests

    do (test) ->

      it 'should encode ' + test[0], ->

        encodeTest
          value: (enbyte, output) -> enbyte.int test[0], output
          valid: (buffer) ->
            assert.equal buffer.length, test[1].length
            assert.deepEqual buffer, test[1]

      switch test[1].length

        when 1 then it 'should encode ' + test[0] + ' with int0()', ->
          encodeTest
            value: (enbyte, output) -> enbyte.int0 test[0], output
            valid: (buffer) ->
              assert.equal buffer.length, test[1].length
              assert.deepEqual buffer, test[1]

        when 2 then it 'should encode ' + test[0] + ' with int1()', ->
          encodeTest
            value: (enbyte, output) -> enbyte.int1 test[0], output
            valid: (buffer) ->
              assert.equal buffer.length, test[1].length
              assert.deepEqual buffer, test[1]

        when 3 then it 'should encode ' + test[0] + ' with int2()', ->
          encodeTest
            value: (enbyte, output) -> enbyte.int2 test[0], output
            valid: (buffer) ->
              assert.equal buffer.length, test[1].length
              assert.deepEqual buffer, test[1]

        when 4 then it 'should encode ' + test[0] + ' with int3()', ->
          encodeTest
            value: (enbyte, output) -> enbyte.int3 test[0], output
            valid: (buffer) ->
              assert.equal buffer.length, test[1].length
              assert.deepEqual buffer, test[1]

        when 5 then it 'should encode ' + test[0] + ' with int4()', ->
          encodeTest
            value: (enbyte, output) -> enbyte.int4 test[0], output
            valid: (buffer) ->
              assert.equal buffer.length, test[1].length
              assert.deepEqual buffer, test[1]

        when 6 then it 'should encode ' + test[0] + ' with int5()', ->
          encodeTest
            value: (enbyte, output) -> enbyte.int5 test[0], output
            valid: (buffer) ->
              assert.equal buffer.length, test[1].length
              assert.deepEqual buffer, test[1]

        when 7 then it 'should encode ' + test[0] + ' with int6()', ->
          encodeTest
            value: (enbyte, output) -> enbyte.int6 test[0], output
            valid: (buffer) ->
              assert.equal buffer.length, test[1].length
              assert.deepEqual buffer, test[1]

        when 8 then it 'should encode ' + test[0] + ' with int7()', ->
          encodeTest
            value: (enbyte, output) -> enbyte.int7 test[0], output
            valid: (buffer) ->
              assert.equal buffer.length, test[1].length
              assert.deepEqual buffer, test[1]


  it 'should error when exceeding 2^53 limit', ->

    encodeTest
      value: (enbyte, output) ->
        result = enbyte.int 18014398509481981, output
        assert result?.error
      valid: ->

  it 'should encode with 8 bytes when told to (pos)', ->

    answer = Buffer.from [ B.P8, 0, 0, 0, 0, 1, 1, 1, 101, ]
    encodeTest
      value: (enbyte, output) -> enbyte.int8 16843109, output
      valid: (buffer) ->
        assert.equal buffer.length, 9
        assert.deepEqual buffer, answer

  it 'should encode with 8 bytes when told to (neg)', ->

    answer = Buffer.from [ B.N8, 0, 0, 0, 0, 1, 1, 1, 101, ]
    encodeTest
      value: (enbyte, output) -> enbyte.int8 -16843109, output
      valid: (buffer) ->
        assert.equal buffer.length, 9
        assert.deepEqual buffer, answer
