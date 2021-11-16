import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dart_bech32/dart_bech32.dart' as lib;
import 'package:dart_bech32/src/models.dart';
import 'package:test/test.dart';

import 'fixtures/fixtures.dart';

void testValidFixture(Fixture f, lib.Bech32Codec bech32) {
  if (f.hex != null) {
    test('fromWords/toWords ${f.hex}', () {
      Uint8List? words;
      Uint8List? bytes;

      try {
        words = bech32.toWords(Uint8List.fromList(hex.decode(f.hex!)));
        bytes = bech32.fromWords(Uint8List.fromList(f.words!));
      } catch (e) {
        expect(words, isNotNull);
        expect(bytes, isNotNull);
        return;
      }
      expect(hex.encode(words), equals(hex.encode(f.words!)));
      expect(hex.encode(bytes), equals(f.hex));
    });
  }
  test('encode ${f.prefix} ${f.hex ?? f.words}', () {
    expect(
        bech32.encode(
            Decoded(prefix: f.prefix!, words: f.words!, limit: f.limit ?? 90)),
        equals(f.string!.toLowerCase()));
  });
  test('decode ${f.string}', () {
    final expected = Decoded(
      prefix: f.prefix!.toLowerCase(),
      words: f.words!,
    );
    expect(bech32.decode(f.string!, f.limit ?? 90), equals(expected));
  });
  test('fails for ${f.string} with 1 bit flipped', () {
    final buffer = utf8.encode(f.string!);
    buffer[f.string!.lastIndexOf('1') + 1] ^=
        0x1; // flip a bit, after the prefix
    final str = utf8.decode(buffer);
    String errMsg = 'No-Error';
    try {
      bech32.decode(str, f.limit ?? 90);
    } catch (e) {
      errMsg = e.toString();
    }
    expect(errMsg, matches(RegExp('Invalid checksum|Unknown character')));
  });
  final wrongBech32 = bech32.encodingConst == lib.bech32.encodingConst
      ? lib.bech32m
      : lib.bech32;
  test('fails for ${f.string} with wrong encoding', () {
    String errMsg = 'No-Error';
    try {
      wrongBech32.decode(f.string!, f.limit ?? 90);
    } catch (e) {
      errMsg = e.toString();
    }
    expect(errMsg, matches(RegExp('Invalid checksum')));
  });
}

void testInvalidFixture(Fixture f, lib.Bech32Codec bech32) {
  if (f.prefix != null && f.words != null) {
    test('encode fails with (${f.exception})', () {
      String errMsg = 'No-Error';
      try {
        bech32.encode(
            Decoded(prefix: f.prefix!, words: f.words!, limit: f.limit ?? 90));
      } catch (e) {
        errMsg = e.toString();
      }
      expect(errMsg, matches(RegExp(f.exception!)));
    });
  }
  if (f.string != null || f.stringHex != null) {
    final str = f.string ??
        hex.decode(f.stringHex!).map((e) => String.fromCharCode(e)).join('');

    test('decode fails for $str (${f.exception})', () {
      String errMsg = 'No-Error';
      try {
        bech32.decode(str, f.limit ?? 90);
      } catch (e) {
        errMsg = e.toString();
      }
      expect(errMsg, matches(RegExp(f.exception!)));
    });
  }
}

void main() {
  group('bech32', () {
    group('valid', () {
      for (var f in fixtures[FixtureEnum.bech32]!['valid']!) {
        testValidFixture(f, lib.bech32);
      }
    });
    group('invalid', () {
      for (var f in fixtures[FixtureEnum.bech32]!['invalid']!) {
        testInvalidFixture(f, lib.bech32);
      }
    });
  });
  group('bech32m', () {
    group('valid', () {
      for (var f in fixtures[FixtureEnum.bech32m]!['valid']!) {
        testValidFixture(f, lib.bech32m);
      }
    });
    group('invalid', () {
      for (var f in fixtures[FixtureEnum.bech32m]!['invalid']!) {
        testInvalidFixture(f, lib.bech32m);
      }
    });
  });
  group('fromWords', () {
    for (var f in fixtures[FixtureEnum.fromWords]!['invalid']!) {
      test('fromWords fails with ${f.exception}', () {
        String errMsg = 'No-Error';
        try {
          lib.bech32.fromWords(f.words!);
        } catch (e) {
          errMsg = e.toString();
        }
        expect(errMsg, matches(RegExp(f.exception!)));
      });
    }
    test('fromWords accept bytes as Uint8List', () {
      final bytes = Uint8List.fromList([
        0x00,
        0x11,
        0x22,
        0x33,
        0xff,
      ]);
      final words = lib.bech32.toWords(bytes);

      expect(
          hex.encode(words), equals(hex.encode([0, 0, 8, 18, 4, 12, 31, 31])));
    });
  });
}
