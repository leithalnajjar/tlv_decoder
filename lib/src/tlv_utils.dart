import 'dart:typed_data';

import 'package:tlv_decoder/src/model/tlv_model.dart';

/// Utilities to encode and decode TLV (Type-Length-Value) byte sequences.
///
/// Length fields are handled according to the BER/DER rules:
///
/// * `0x00`–`0x7F` – short form, for lengths `0`–`127`.
/// * `0x81 LL` – long form, for lengths `128`–`255`.
/// * `0x82 LL LL` – long form, for lengths `256`–`65535`.
/// * `0x83 …` / `0x84 …` – long form, for larger lengths (up to 4 length
///   octets, i.e. `4294967295`).
///
/// Tags/types are treated as a single byte.
class TlvUtils {
  TlvUtils._();

  /// Decodes [data] into a list of [TLV] entries.
  ///
  /// Each entry is read as a single type byte, a BER/DER length field and the
  /// value bytes described by that length.
  ///
  /// Throws a [FormatException] when [data] is truncated or uses an
  /// unsupported (indefinite) length form.
  static List<TLV> decode(Uint8List data) {
    final tlvList = <TLV>[];
    var offset = 0;
    while (offset < data.length) {
      // Type field (1 byte).
      final type = data[offset];
      offset += 1;

      if (offset >= data.length) {
        throw const FormatException('Truncated TLV: missing length field.');
      }

      // Length field (short or long form).
      final lengthField = _decodeLength(data, offset);
      final valueLength = lengthField.value;
      offset = lengthField.nextOffset;

      if (offset + valueLength > data.length) {
        throw FormatException(
          'Truncated TLV: value needs $valueLength byte(s) but only '
          '${data.length - offset} remain.',
        );
      }

      final value = data.sublist(offset, offset + valueLength);
      offset += valueLength;

      tlvList.add(TLV(type: type, length: valueLength, value: value));
    }
    return tlvList;
  }

  /// Encodes [tlvList] into a single [Uint8List].
  ///
  /// The length field of every entry is derived from its value, so
  /// [TLV.length] does not need to be set correctly for encoding.
  static Uint8List encode(List<TLV> tlvList) {
    final builder = BytesBuilder(copy: false);
    for (final tlv in tlvList) {
      builder.addByte(tlv.type & 0xFF);
      builder.add(_encodeLength(tlv.value.length));
      builder.add(tlv.value);
    }
    return builder.toBytes();
  }

  /// Decodes a BER/DER length field that starts at [offset] in [data].
  static _LengthField _decodeLength(Uint8List data, int offset) {
    final first = data[offset];

    // Short form: the high bit is clear and the byte is the length itself.
    if ((first & 0x80) == 0) {
      return _LengthField(first, offset + 1);
    }

    // Long form: the low 7 bits give the number of subsequent length octets.
    final octetCount = first & 0x7F;
    if (octetCount == 0) {
      throw const FormatException('Indefinite length form is not supported.');
    }
    if (octetCount > 4) {
      throw FormatException(
        'Length field too large: $octetCount octets (max 4 supported).',
      );
    }
    if (offset + 1 + octetCount > data.length) {
      throw const FormatException('Truncated TLV: incomplete length field.');
    }

    var length = 0;
    for (var i = 0; i < octetCount; i++) {
      length = (length << 8) | (data[offset + 1 + i] & 0xFF);
    }
    return _LengthField(length, offset + 1 + octetCount);
  }

  /// Encodes [length] as a BER/DER length field.
  static Uint8List _encodeLength(int length) {
    if (length < 0) {
      throw ArgumentError.value(length, 'length', 'must be non-negative');
    }

    // Short form.
    if (length < 0x80) {
      return Uint8List.fromList([length]);
    }

    // Long form: emit the minimum number of big-endian octets.
    final octets = <int>[];
    var remaining = length;
    while (remaining > 0) {
      octets.insert(0, remaining & 0xFF);
      remaining >>= 8;
    }
    return Uint8List.fromList([0x80 | octets.length, ...octets]);
  }
}

/// Result of decoding a length field: the decoded [value] and the [nextOffset]
/// at which the value bytes begin.
class _LengthField {
  final int value;
  final int nextOffset;

  const _LengthField(this.value, this.nextOffset);
}
