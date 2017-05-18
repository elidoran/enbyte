assert = require 'assert'

B = require '@endeo/bytes'
buildEnbyte = require '../../lib/index.coffee'
Output = require '@endeo/output'
defaultBuildOptions = bytes:B, unstring: string: ->

module.exports = ({buildOptions, value, valid}) ->

  enbyte = buildEnbyte buildOptions ? defaultBuildOptions
  output = Output()
  value enbyte, output
  result = output.complete()
  buffer = result?.buffer
  assert result, 'should provide a result'
  assert.equal Buffer.isBuffer(buffer), true, 'result should have a Buffer'
  valid buffer
