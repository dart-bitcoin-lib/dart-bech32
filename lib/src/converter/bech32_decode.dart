import 'dart:typed_data';

import 'package:dart_bech32/src/abstracts/converter_abstract.dart';
import 'package:dart_bech32/src/enum.dart';
import 'package:dart_bech32/src/helpers/common.dart';
import 'package:dart_bech32/src/models.dart';

/// The canonical instance of [Bech32Decoder].
const bech32Decoder = Bech32Decoder._();
const bech32mDecoder = Bech32Decoder._(EncodingEnum.bech32m);

/// Bec32 Decoder
class Bech32Decoder extends ConverterAbstract<Encoded, Decoded> {
  const Bech32Decoder._([EncodingEnum encodingConst = EncodingEnum.bech32])
      : super(encodingConst);

  @override
  Decoded convert(Encoded input) {
    return _decode(input.data, input.limit);
  }

  /// Decode
  Decoded _decode(String str, [int limit = 90]) {
    if (str.length < 8) throw Exception('$str too short');
    if (str.length > limit) throw Exception('Exceeds length limit');

    // don't allow mixed case
    final lowered = str.toLowerCase();
    final uppered = str.toUpperCase();
    if (str != lowered && str != uppered) {
      throw Exception('Mixed-case string $str');
    }
    str = lowered;

    final split = str.lastIndexOf('1');
    if (split == -1) throw Exception('No separator character for $str');
    if (split == 0) throw Exception('Missing prefix for $str');

    final prefix = str.substring(0, split);
    final wordChars = str.substring(split + 1);
    if (wordChars.length < 6) throw Exception('Data too short');

    int chk = prefixChk(prefix);

    final List<int> words = [];
    for (int i = 0; i < wordChars.length; ++i) {
      final c = wordChars[i];
      final v = alphabet.indexOf(c);
      if (v == -1) throw Exception('Unknown character $c');
      chk = polymodStep(chk) ^ v;

      // not in the checksum?
      if (i + 6 >= wordChars.length) continue;
      words.add(v);
    }

    if (chk != (encodingConst == EncodingEnum.bech32 ? 1 : 0x2bc830a3)) {
      throw Exception('Invalid checksum for $str');
    }
    return Decoded(prefix: prefix, words: Uint8List.fromList(words));
  }
}
