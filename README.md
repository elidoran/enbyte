# enbyte
[![Build Status](https://travis-ci.org/elidoran/enbyte.svg?branch=master)](https://travis-ci.org/elidoran/enbyte)
[![Dependency Status](https://gemnasium.com/elidoran/enbyte.png)](https://gemnasium.com/elidoran/enbyte)
[![npm version](https://badge.fury.io/js/enbyte.svg)](http://badge.fury.io/js/enbyte)
[![Coverage Status](https://coveralls.io/repos/github/elidoran/enbyte/badge.svg?branch=master)](https://coveralls.io/github/elidoran/enbyte?branch=master)

Efficiently encode objects, arrays, strings into binary data.

See packages:

1. [endeo](https://www.npmjs.com/package/endeo)
2. [debyte](https://www.npmjs.com/package/debyte)
3. [unstring](https://www.npmjs.com/package/unstring)
4. [@endeo/bytes](https://www.npmjs.com/package/@endeo/bytes)
4. [@endeo/output](https://www.npmjs.com/package/@endeo/output)


## Install

```sh
# use with standard bytes/unstring:
npm install --save enbyte unstring @endeo/bytes

# use with custom bytes/unstring options:
npm install --save enbyte
```


## Usage

Primarily intended for use via the [endeo](https://www.npmjs.com/package/endeo) package.

It's possible to use directly on its own like this:

```javascript
// get the builder
var buildEnbyte = require('enbyte')

var enbyte = buildEnbyte()

var buffer

// create an Output thru convenience method:
var output = enbyte.output()

// provide an object, array, string, number
enbyte.encode({ some: 'object' }, output)
enbyte.encode([ 'some', 'array', {three:true} ], output)
enbyte.encode('something', output)
enbyte.encode(12345, output)

// when the type is known already, this is faster:
enbyte.object({ some: 'object' }, output)
enbyte.array([ 'some', 'array', {three:true} ], output)
enbyte.string('something', output)
enbyte.int(12345, output)
enbyte.float(1.23, output)

// get the buffer containing it all from output at any time:
// (could have done it after each call above...)
buffer = output.complete()

// both num() and int() would use fewest bytes possible.
// to control the number of bytes, use int#():
//   int1() int2() int3() int4() int5() int6() int7() int8()
// for example:
enbyte.int2(123, output)

// create your own Output instance with custom options:
Output = require('@endeo/output')
var output = Output({size:1024})

// then use it:
enbyte.object({ some: 'object' }, output)


// an Output allows streaming it out:
var stream = someStream()
output = enbyte.output(stream.write, stream)

// or with a transform:
var transform = someTransform()
output = enbyte.output(transform.push, transform)

// use the output and chunks will be sent to the stream:
enbyte.object({ key: '1' }, output)
enbyte.object({ some: 'object' }, output)
enbyte.object({ another: 'object' }, output)

// to "flush" all bytes stored up in the output use
// the same function which would have returned a buffer
// if you didn't give it the stream stuff:
output.complete()
```


# [MIT License](LICENSE)
