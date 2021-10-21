/// Polymod Step
int polymodStep(int pre) {
  final b = pre >> 25;
  return (((pre & 0x1ffffff) << 5) ^
      (-((b >> 0) & 1) & 0x3b6a57b2) ^
      (-((b >> 1) & 1) & 0x26508e6d) ^
      (-((b >> 2) & 1) & 0x1ea119fa) ^
      (-((b >> 3) & 1) & 0x3d4233dd) ^
      (-((b >> 4) & 1) & 0x2a1462b3));
}

/// Prefix Check
int prefixChk(String prefix) {
  int chk = 1;
  for (int i = 0; i < prefix.length; ++i) {
    int c = prefix.codeUnitAt(i);
    if (c < 33 || c > 126) throw Exception('Invalid prefix (' + prefix + ')');

    chk = polymodStep(chk) ^ (c >> 5);
  }
  chk = polymodStep(chk);

  for (int i = 0; i < prefix.length; ++i) {
    final v = prefix.codeUnitAt(i);
    chk = polymodStep(chk) ^ (v & 0x1f);
  }
  return chk;
}
