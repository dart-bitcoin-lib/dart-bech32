import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_bech32/src/converter/bech32_decode.dart';
import 'package:dart_bech32/src/converter/bech32_encoder.dart';
import 'package:dart_bech32/src/enum.dart';
import 'package:dart_bech32/src/models.dart';

/// The canonical instance of [Bech32] for bech32.
const bech32 = Bech32._();

/// The canonical instance of [Bech32] for bech32m.
const bech32m = Bech32._(EncodingEnum.bech32m);

/// A BIP173/BIP350 compatible Bech32/Bech32m encoding/decoding package.
class Bech32 extends Codec<Decoded, Encoded> {
  final EncodingEnum encodingConst;

  const Bech32._([this.encodingConst = EncodingEnum.bech32]) : super();

  @override
  Bech32Decoder get decoder =>
      encodingConst == EncodingEnum.bech32 ? bech32Decoder : bech32mDecoder;

  @override
  Bech32Encoder get encoder =>
      encodingConst == EncodingEnum.bech32 ? bech32Encoder : bech32mEncoder;

  Uint8List toWords(Uint8List bytes) {
    return _convert(data: bytes, inBits: 8, outBits: 5, pad: true);
  }

  Uint8List fromWords(Uint8List words) {
    return _convert(data: words, inBits: 5, outBits: 8, pad: false);
  }

  Uint8List _convert({
    required Uint8List data,
    required int inBits,
    required int outBits,
    required bool pad,
  }) {
    int value = 0;
    int bits = 0;
    final maxV = (1 << outBits) - 1;

    final List<int> result = [];
    for (int i = 0; i < data.length; ++i) {
      value = (value << inBits) | data[i];
      bits += inBits;

      while (bits >= outBits) {
        bits -= outBits;
        result.add((value >> bits) & maxV);
      }
    }

    if (pad) {
      if (bits > 0) {
        result.add((value << (outBits - bits)) & maxV);
      }
    } else {
      if (bits >= inBits) throw Exception('Excess padding');
      if (((value << (outBits - bits)) & maxV) != 0) {
        throw Exception('Non-zero padding');
      }
    }

    return Uint8List.fromList(result);
  }
}
