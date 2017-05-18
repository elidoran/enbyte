# create the value scale based on how many bytes we use.
# subtract the previous byte size's max value to slide larger values down into
# smaller byte sizes.
# stop that once we are at 7 bytes because JS can't handle math with values above 2^53.
max = do ->
  prop = (v) -> value: v, writable: false, configurable: false, enumerable: false
  Object.create null,
    b0: prop 101              # special tiny ints go up to 100, max + 1 = 101
    b1: prop 357              # b0 + 2^8 : 101               + 256
    b2: prop 65893            # b1 + 2^16: 357               + 65,536
    b3: prop 16843109         # b2 + 2^24: 65,893            + 16,777,573
    b4: prop 4311810405       # b3 + 2^32: 16,843,109        + 4,294,967,296
    b5: prop 1103823438181    # b4 + 2^40: 4,311,810,405     + 1,099,511,627,776
    b6: prop 282578800148837  # b5 + 2^48: 1,103,823,438,181 + 281,474,976,710,656
    # b7: prop 18014398509481984 # 2^54
    limit: prop 9007199254740992 # 2^53 = 9,007,199,254,740,992

# the max number of bytes Buffer.writeUIntBE can write.
# any more than this requires some extra work.
# so, the seven bytes number value needs this.
POW_SIX = Math.pow 2, 48

# Enbyte's int() method.
# sends int using least bytes.
module.exports = (num, output) ->

  # first test if it fits into a special byte...
  if 0 <= num <= @B.MAX_POS
    output.marker num # the num is the B byte for it

  # negative values
  else if -100 <= num <= -1
    output.marker Math.abs(num) + @B.MAX_POS

  else # use ranges

    if num > 0

      value  = num
      offset = 0

    else

      value = Math.abs num
      offset = 8

    switch

      when value < max.b1
        output.marker @B.P1 + offset
        output.byte value - max.b0

      when value < max.b2
        output.marker @B.P2 + offset
        output.int value - max.b1, 2

      when value < max.b3
        output.marker @B.P3 + offset
        output.int value - max.b2, 3

      when value < max.b4
        output.marker @B.P4 + offset
        output.int value - max.b3, 4

      when value < max.b5
        output.marker @B.P5 + offset
        output.int value - max.b4, 5

      when value < max.b6
        output.marker @B.P6 + offset
        output.int value - max.b5, 6

      # NOTE: JS can't handle math on values above 2^53
      when value <= max.limit
        output.prepare 8
        output.marker @B.P7 + offset
        output.buf.writeUInt8 value / POW_SIX, output.index, true
        output.buf.writeUIntBE value, output.index + 1, 6, true
        output.increment 7

      else # NOTE: JS can't handle math on values above 2^53
        return error: 'exceeds 2^53 limit', value: value
        # output.prepare 9
        # output.marker @B.P8 + offset
        # output.buf.writeUInt16BE value / POW_SIX, output.index, true
        # output.buf.writeUIntBE value, output.index + 1, 6, true
        # output.increment 8

    return


# export the helper object
module.exports.max = max
