import 'dart:typed_data';

import 'package:dart_bech32/src/abstracts/converter_abstract.dart';
import 'package:dart_bech32/src/enum.dart';
import 'package:dart_bech32/src/helpers/common.dart';
import 'package:dart_bech32/src/models.dart';

/// The canonical instance of [Bech32Encoder] for bech32.
const Bech32Encoder bech32Encoder = Bech32Encoder._();

/// The canonical instance of [Bech32Encoder] for bech32m.
const Bech32Encoder bech32mEncoder = Bech32Encoder._(EncodingEnum.bech32m);

/// Bec32 Encoder
class Bech32Encoder extends ConverterAbstract<Decoded, String> {
  const Bech32Encoder._([EncodingEnum encodingConst = EncodingEnum.bech32])
      : super(encodingConst);

  @override
  String convert(Decoded input) {
    String prefix = input.prefix;
    Uint8List words = input.words;

    if (prefix.length + 7 + words.length > input.limit) {
      throw Exception('Exceeds length limit');
    }

    prefix = prefix.toLowerCase();

    // determine chk mod
    int chk = prefixChk(prefix);

    String result = prefix + '1';
    for (int i = 0; i < words.length; ++i) {
      final x = words[i];
      if (x >> 5 != 0) throw Exception('Non 5-bit word');

      chk = polymodStep(chk) ^ x;
      result += alphabet[x];
    }

    for (int i = 0; i < 6; ++i) {
      chk = polymodStep(chk);
    }
    chk ^= encodingConst == EncodingEnum.bech32 ? 1 : 0x2bc830a3;

    for (int i = 0; i < 6; ++i) {
      final v = (chk >> ((5 - i) * 5)) & 0x1f;
      result += alphabet[v];
    }

    return result;
  }
}
