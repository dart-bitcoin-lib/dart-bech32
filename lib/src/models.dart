import 'dart:convert';
import 'dart:typed_data';

/// Decoded Output Model
class Decoded {
  String prefix;
  Uint8List words;

  int limit;

  Decoded({required this.prefix, required this.words, this.limit = 90});

  @override
  String toString() {
    return '{"prefix": "$prefix", "words": [${words.join(', ')}]}';
  }

  @override
  bool operator ==(covariant Decoded other) {
    return prefix == other.prefix &&
        utf8.decode(words) == utf8.decode(other.words) &&
        limit == other.limit;
  }

  @override
  int get hashCode => Object.hash(prefix, words, limit);
}

/// Encoded Output Model
class Encoded {
  String data;
  int limit;

  Encoded({required this.data, this.limit = 90});

  @override
  String toString() {
    return data;
  }

  @override
  bool operator ==(covariant Encoded other) {
    return data == other.data && limit == other.limit;
  }

  @override
  int get hashCode => Object.hash(data, limit);
}
