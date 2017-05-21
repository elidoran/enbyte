assert      = require 'assert'
B           = require '@endeo/bytes'
buildEnbyte = require '../../lib/index.coffee'
encodeTest  = require '../helpers/encode-tester.coffee'

describe 'test enbyte', ->

  it 'should build', -> assert buildEnbyte()

  it 'should error for invalid type', ->

    result = buildEnbyte().encode()
    assert result?.error


  it 'should build a gathering output', ->

    output = buildEnbyte().output()
    assert output

  it 'should build a streaming output', ->

    writer = {}
    target = {}
    output = buildEnbyte().output writer, target
    assert output
    assert.equal output.writer, writer
    assert.equal output.target, target


  it 'should encode true via bool', ->

    encodeTest
      value: (enbyte, output) -> enbyte.bool true, output
      valid: (buffer) -> assert.equal buffer[0], B.TRUE

  it 'should encode false via bool', ->

    encodeTest
      value: (enbyte, output) -> enbyte.bool false, output
      valid: (buffer) -> assert.equal buffer[0], B.FALSE

  it 'should encode null in encode()', ->

    encodeTest
      value: (enbyte, output) -> enbyte.encode null, output
      valid: (buffer) -> assert.equal buffer[0], B.NULL


  it 'should encode num via int', ->

    encodeTest
      value: (enbyte, output) -> enbyte.num 100, output
      valid: (buffer) -> assert.equal buffer[0], 100


  it 'should encode num via float', ->

    encodeTest
      value: (enbyte, output) -> enbyte.num 1.25, output
      valid: (buffer) -> assert.equal buffer.readFloatBE(1, true), 1.25


  it 'should encode via object (empty)', ->

    encodeTest
      value: (enbyte, output) -> enbyte.encode {}, output
      valid: (buffer) ->
        assert.equal buffer[0], B.OBJECT
        assert.equal buffer[1], B.SUB_TERMINATOR


  it 'should encode via object', ->

    encodeTest
      value: (enbyte, output) -> enbyte.encode {a:1}, output
      valid: (buffer) ->
        assert.equal buffer[0], B.OBJECT
        assert.equal buffer[1], B.STRING
        assert.equal buffer[2], 1
        assert.equal buffer[3], 97
        assert.equal buffer[4], 1
        assert.equal buffer[5], B.SUB_TERMINATOR


  it 'should encode via array (empty)', ->

    encodeTest
      value: (enbyte, output) -> enbyte.encode [], output
      valid: (buffer) -> assert.equal buffer[0], B.EMPTY_ARRAY


  it 'should encode via array', ->

    encodeTest
      value: (enbyte, output) -> enbyte.encode [1], output
      valid: (buffer) ->
        assert.equal buffer[0], B.ARRAY
        assert.equal buffer[1], 1
        assert.equal buffer[2], B.SUB_TERMINATOR


  it 'should encode via string', ->

    encodeTest
      value: (enbyte, output) -> enbyte.encode '', output
      valid: (buffer) -> assert.equal buffer[0], B.EMPTY_STRING


  it 'should encode via string and unstring it (known)', ->

    string = 'testing'
    encodeTest
      buildOptions:
        bytes:B
        unstring:
          string: (s) -> if s is string then id:1, known:true
      value: (enbyte, output) -> enbyte.encode string, output
      valid: (buffer) ->
        assert.deepEqual buffer, Buffer.from [ B.GET_STRING, 1 ]

  it 'should encode via string and unstring it (new)', ->

    string = 'testing'
    encodeTest
      buildOptions:
        bytes:B
        unstring:
          string: (s) -> if s is string then id:1, known:false
      value: (enbyte, output) -> enbyte.encode string, output
      valid: (buffer) ->
        assert.deepEqual buffer, Buffer.from [
          B.NEW_STRING, 1, 7, 116, 101, 115, 116, 105, 110, 103
        ]


  it 'should encode via generic', ->

    encodeTest
      value: (enbyte, output) -> enbyte.object {a:1}, output
      valid: (buffer) ->
        assert.deepEqual buffer, Buffer.from [
        # indicator, specifier, length, 'a', value, end-of-object
          B.OBJECT, B.STRING, 1, 0x61, 1, B.SUB_TERMINATOR
        ]


  it 'should encode via special', ->

    encodeTest
      value: (enbyte, output) ->
        object =
          a: 1
          $ENDEO_SPECIAL:
            id: 1
            array: [ { key: 'a', default:1 } ]
        enbyte.object object, output

      valid: (buffer) ->
        assert.deepEqual buffer, Buffer.from [
          # indicator, specifier, end-of-object
          B.SPECIAL, 1, B.DEFAULT, B.SUB_TERMINATOR
        ]

  it 'should encode via special with custom encode', ->

    called = false
    encodeTest
      value: (enbyte, output) ->
        object =
          a: 2
          $ENDEO_SPECIAL:
            id: 1
            array: [ {
              key: 'a', default:1, encode: (enbyte, value, output) ->
                called = true
                enbyte.int0 value, output
            } ]
        enbyte.object object, output

      valid: (buffer) ->
        assert called
        assert.deepEqual buffer, Buffer.from [
          # indicator, specifier, end-of-object
          B.SPECIAL, 1, 2, B.SUB_TERMINATOR
        ]

  it 'should encode via special with an known/expected inner object', ->

    encodeTest
      value: (enbyte, output) ->
        object =
          a:
            b: 3
          $ENDEO_SPECIAL:
            id: 1
            array: [ {
              key: 'a', default:1, array: [
                { key: 'b', default: 2 }
              ]
            } ]
        enbyte.object object, output

      valid: (buffer) ->
        assert.deepEqual buffer, Buffer.from [
          # indicator, specifier, end-of-object
          B.SPECIAL, 1, 3, B.SUB_TERMINATOR
        ]

  it 'should encode via special with an inner special object', ->

    encodeTest
      value: (enbyte, output) ->
        object =
          # outer object with its own spec
          a: 2
          $ENDEO_SPECIAL:
            id: 1
            array: [
              { key: 'a', default:1 }
              { key: 'b' }
            ]
          b:
            # inner special object with its own spec
            c: 4
            $ENDEO_SPECIAL:
              id: 2
              array: [
                { key: 'c', default: 3 }
              ]
        enbyte.object object, output

      valid: (buffer) ->
        assert.deepEqual buffer, Buffer.from [
          # indicator, specifier, end-of-object
          B.SPECIAL, 1, 2, B.SPECIAL, 2, 4, B.SUB_TERMINATOR
        ]

  it 'should encode via special w/out prefix marker', ->

    encodeTest
      value: (enbyte, output) ->
        object =
          a: 1
          $ENDEO_SPECIAL:
            id: 1
            array: [ { key: 'a', default:1 } ]
        output.consumeMarkerIf B.SPECIAL
        enbyte.object object, output

      valid: (buffer) ->
        assert.deepEqual buffer, Buffer.from [
          # indicator, specifier, end-of-object
          1, B.DEFAULT, B.SUB_TERMINATOR
        ]

  it 'should encode via special with multi-byte ID', ->

    encodeTest
      value: (enbyte, output) ->
        object =
          a: 1
          $ENDEO_SPECIAL:
            id: 301
            array: [ { key: 'a', default:1 } ]
        enbyte.object object, output

      valid: (buffer) ->
        assert.deepEqual buffer, Buffer.from [
          # indicator, specifier, end-of-object
          B.SPECIAL, B.P1, 200, B.DEFAULT, B.SUB_TERMINATOR
        ]

  it 'should encode via special with multi-byte ID despite consumeMarkerIf', ->

    encodeTest
      value: (enbyte, output) ->
        object =
          a: 1
          $ENDEO_SPECIAL:
            id: 301
            array: [ { key: 'a', default:1 } ]
        output.consumeMarkerIf B.SPECIAL
        enbyte.object object, output

      valid: (buffer) ->
        assert.deepEqual buffer, Buffer.from [
          # indicator, specifier, end-of-object
          B.SPECIAL, B.P1, 200, B.DEFAULT, B.SUB_TERMINATOR
        ]


  it 'should encode via special and receive an error', ->

    called = false
    result = null
    encodeTest
      value: (enbyte, output) ->
        object =
          a: 2
          $ENDEO_SPECIAL:
            id: 1
            array: [ {
              key: 'a', default:1, encode: (enbyte, value, output) ->
                called = true
                error: 'testing'
            } ]
        result = enbyte.object object, output

      valid: (buffer) ->
        assert called
        assert result?.error


  it 'should encode via float4', ->

    encodeTest
      value: (enbyte, output) -> enbyte.float4 1.25, output
      valid: (buffer) -> assert.equal buffer.readFloatBE(1, true), 1.25

  it 'should encode via float8', ->

    encodeTest
      value: (enbyte, output) -> enbyte.float8 1.23, output
      valid: (buffer) -> assert.equal buffer.readDoubleBE(1, true), 1.23
