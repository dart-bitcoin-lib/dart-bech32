import 'dart:convert';

import 'package:dart_bech32/src/enum.dart';

abstract class ConverterAbstract<S, T> extends Converter<S, T> {
  final alphabet = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
  final EncodingEnum encodingConst;

  const ConverterAbstract([this.encodingConst = EncodingEnum.bech32]) : super();
}
