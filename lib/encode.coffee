# Enbyte's encode() method.
# a generic entry point for any type of value.
# if output is in sync mode it will return a Buffer with the whole encoding.
# stream mode will push Buffer instances as it generates them and return
# only {success:true}
module.exports = (thing, output) ->

  switch typeof thing

    when 'object'

      if Array.isArray thing then @array thing, output

      else if thing is null then output.marker @B.NULL

      else @object thing, output

    when 'string' then @string thing, output

    when 'number' then @num thing, output

    # when 'function' then @fn thing, output

    else error: 'not an object, array, string, or number', value: thing
