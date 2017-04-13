assert = require 'assert'

buildEnbyte = require '../../lib/index.coffee'

describe 'test enbyte', ->

  it 'should build', -> assert buildEnbyte()

  it 'should encode an object'
  it 'should encode an array'
  it 'should encode a string'
  it 'should encode a nested object'

  it 'should decode an object'
  it 'should decode an array'
  it 'should decode a string'
  it 'should decode a nested object'
