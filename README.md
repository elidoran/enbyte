# enbyte
[![Build Status](https://travis-ci.org/elidoran/enbyte.svg?branch=master)](https://travis-ci.org/elidoran/enbyte)
[![Dependency Status](https://gemnasium.com/elidoran/enbyte.png)](https://gemnasium.com/elidoran/enbyte)
[![npm version](https://badge.fury.io/js/enbyte.svg)](http://badge.fury.io/js/enbyte)
[![Coverage Status](https://coveralls.io/repos/github/elidoran/enbyte/badge.svg?branch=master)](https://coveralls.io/github/elidoran/enbyte?branch=master)

Efficiently encode objects, arrays, strings into binary data.

See packages:

1. [endeo](https://www.npmjs.com/package/endeo)
2. [debyte](https://www.npmjs.com/package/debyte)
3. [debytes](https://www.npmjs.com/package/debytes)
4. [destring](https://www.npmjs.com/package/destring)

NOTE: placeholder

## Install

```sh
npm install enbyte --save
```


## Usage


```javascript
    // get the builder
var buildEnbyte = require('enbyte')

  // build one
  , enbyte = buildEnbyte({
    // the delimiter between array elements,
    // and a child object and the rest of the parent object.
    delim: 0xFF // default
  })

  , buffer

// provide an object, array, string, number
buffer = enbyte.encode({ some: 'thing' })
buffer = enbyte.encode([ 'one', 'two', {three:true} ])
buffer = enbyte.encode('something')
buffer = enbyte.encode(12345)

// when the type is known already, this is faster:
buffer = enbyte.object({ some: 'thing' })
buffer = enbyte.array([ 'one', 'two', {three:true} ])
buffer = enbyte.string('something')
buffer = enbyte.num(12345)

// instead of num():
buffer = enbyte.byte(123)
// TODO: add the other specific number encoders

// have it write out the bytes to a buffer instead of building its own
// use an endeo-output object to manage buffer chunks
// and streaming.
var output = new Output({size:1024})

enbyte.object({ some: 'thing' }, output)

// write some other bytes to the output

// then get all the bytes together in one Buffer instance.
buffer = output.complete()
// the above produces the same result as:
//   buffer = enbyte.object({ some: 'thing' })


// an Output (endeo-output) allows streaming it out:
var stream = someStream()
output = new Output({size:1024, write:stream.write, target:stream})

enbyte.object({ key: '1' }, output)

stream.write(someSpearatorValueInBuffer)

enbyte.object({ some: 'thing' }, output)

stream.write(someSpearatorValueBuffer)

enbyte.object({ some: 'thing' }, output)

stream.write(someSpearatorValueBuffer)

// see `endeo` for full streaming handled for you
```


# [MIT License](LICENSE)
