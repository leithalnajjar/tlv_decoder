import 'dart:typed_data';

/// A single Type-Length-Value (TLV) entry.
class TLV {
  /// The tag/type byte.
  final int type;

  /// The number of value bytes.
  ///
  /// This should equal `value.length`. It is ignored by [TlvUtils.encode],
  /// which always derives the length from [value].
  final int length;

  /// The raw value bytes.
  final Uint8List value;

  /// Creates a [TLV] entry.
  TLV({
    required this.type,
    required this.length,
    required this.value,
  });

  @override
  String toString() => 'TLV(type: 0x${type.toRadixString(16).padLeft(2, '0')}, '
      'length: $length, value: $value)';

  @override
  bool operator ==(Object other) =>
      other is TLV &&
      other.type == type &&
      other.length == length &&
      _bytesEqual(other.value, value);

  @override
  int get hashCode => Object.hash(type, length, Object.hashAll(value));

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
