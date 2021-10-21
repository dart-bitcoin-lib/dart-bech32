# dart_bech32

A [BIP173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki)
/ [BIP350](https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki) compatible Bech32/Bech32m encoding/decoding
package.

## Example

``` dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_bech32/dart_bech32.dart';
import 'package:dart_bech32/src/models.dart';

void main() {
  final decoded1 = bech32
      .decode(Encoded(data: 'abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw'));
  print(decoded1);
// => {"prefix": "abcdef", "words": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
  final decoded2 = bech32m
      .decode(Encoded(data: 'abcdef1l7aum6echk45nj3s0wdvt2fg8x9yrzpqzd3ryx'));
  print(decoded2);

// => {"prefix": "abcdef", "words": [31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

  // toWords etc. are available on both bech32 and bech32m objects
  final words = bech32.toWords(Uint8List.fromList(utf8.encode('foobar')));

  final encoded1 = bech32.encode(Decoded(prefix: 'foo', words: words));
  print(encoded1);
  // => 'foo1vehk7cnpwgry9h96'

  final encoded2 = bech32m.encode(Decoded(prefix: 'foo', words: words));
  print(encoded2);
  // => 'foo1vehk7cnpwgkc4mqc'
}
```

### Advanced

BIP173 enforces a limitation of 90 characters, if extend the `limit` parameter beyond this, be aware that
the [effectiveness of checksum decreases as the length increases](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#checksum-design)
.

It is highly recommended **NOT** exceed 1023 characters, as the module could only guarantee detecting 1 error.

## License [MIT](LICENSE)