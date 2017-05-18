format = require 'comma-number'
pad    = require 'pad'

Output = require '@endeo/output'
enbyte = require('../lib/encode/num.coffee').int
zigzag = require 'signed-varint'
varint = require 'varint'

# how many repeats?
repeat = do ->
  index = process.argv.indexOf '--repeat'
  if index > -1 then Number process.argv[index + 1]
  else 1

buffer = Buffer.allocUnsafe 16
output = new Output size:16

zigzage = (num) ->
  buffer[0] = (1 << 3) + 1 # really it sets field ID and type
  zigzag.encode num, buffer, 1
  zigzag.encode.bytes + 1 # plus 1 cuz they need a byte with field ID and type

zigzage.decode = -> zigzag.decode buffer, 1

varinte = (num) ->
  buffer[0] = (1 << 3) + 1 # really it sets field ID and type
  varint.encode num, buffer, 1
  varint.encode.bytes + 1 # plus 1 cuz they need a byte with field ID and type

varinte.decode = -> varint.decode buffer, 1

mine = (num) ->
  output.index = 0
  enbyte num, output
  output.index

INT = Math.pow 2, 32
mine.decode = ->
  # output.buf[0 ... output.index]
  first = 0
  start = 1
  byte = output.buf[first]
  switch output.index
    when 1
      if byte <= 100 then byte
      else (byte - 100) * -1
    when 2
      (101 + output.buf[start]) * (if byte is 0xDE then 1 else -1)
    when 3
      (357 + output.buf.readUInt16BE(start, true))  * (if byte is 0xDF then 1 else -1)
    when 4
      (65893 + output.buf.readUIntBE(start, 3, true)) * (if byte is 0xE0 then 1 else -1)
    when 5
      (16843109 + output.buf.readUInt32BE(start, true)) * (if byte is 0xE1 then 1 else -1)
    when 6
      (4311810405 + output.buf.readUIntBE(start, 5, true)) * (if byte is 0xE2 then 1 else -1)
    when 7
      (1103823438181 + output.buf.readUIntBE(start, 6, true)) * (if byte is 0xE3 then 1 else -1)

    when 8
      top = output.buf[start]
      bottom = output.buf.readUIntBE start + 1, 6, true
      (((top << 16) * INT) + bottom) * (if byte is 0xE4 then 1 else -1)


console.log """
compare encodings

  repeat: #{format repeat}

     | === |  name  | B | time            |  value
---------------------------------------------------------------------------------
"""

nums = [
  1
  -1
  100
  -100
  101
  -101

  127
  -127
  128
  -128

  255
  -255
  256
  -256

  356
  -356
  357
  -357

  65535
  -65535
  65536
  -65536

  65892
  -65892
  65893
  -65893

  16777215
  -16777215
  16777216
  -16777216

  16843108
  -16843108
  16843109
  -16843109

  4294967295
  -4294967295
  4294967296
  -4294967296

  4311810404
  -4311810404
  4311810405
  -4311810405

  1099511627775
  -1099511627775
  1099511627776
  -1099511627776

  1103823438180
  -1103823438180
  1103823438181
  -1103823438181

  281474976710655
  -281474976710655
  281474976710656
  -281474976710656

  282578800148836
  -282578800148836
  282578800148837
  -282578800148837
]

test = (action, num, report) ->

  bytes = action num
  result = action.decode()
  if result is num then ['+', bytes ]
  else
    if report then console.log "\n!!! wrong result: #{num} !== #{result}\n"
    ['X', 'x']



run = (action, num) ->

  # once to warm it up ;P
  action num for i in [0 ... repeat]

  elapsed = process.hrtime()

  # now measure this
  action num for i in [0 ... repeat]

  process.hrtime elapsed

print = (index, test, name, time, num) ->
  [seconds, nanos] = time
  process.stdout.write '\n' + pad(4, index) + " |  #{test[0]}  | #{name} | #{test[1]} | #{pad(3, format seconds)} s #{pad(11, format nanos)} ns | #{format num}"

for num, index in nums

  print index,  test(zigzage, num), 'zigzag', run(zigzage, num), num
  print '    ', test(varinte, num), 'varint', run(varinte, num), num
  print '    ', test(mine, num, true),    '  mine', run(mine, num), num
  console.log '\n'

console.log '\n\ncomplete\n'
