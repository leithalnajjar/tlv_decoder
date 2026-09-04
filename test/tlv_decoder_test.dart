import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlv_decoder/tlv_decoder.dart';

void main() {
  group('encode', () {
    test('encodes multiple entries with short-form lengths', () {
      final encoded = TlvUtils.encode([
        TLV(type: 1, length: 3, value: Uint8List.fromList([0x41, 0x42, 0x43])),
        TLV(type: 2, length: 2, value: Uint8List.fromList([0x44, 0x45])),
      ]);

      expect(
        encoded,
        equals([0x01, 0x03, 0x41, 0x42, 0x43, 0x02, 0x02, 0x44, 0x45]),
      );
    });

    // Regression for GitHub issue #1: a value of length 0x90 (144) must be
    // encoded as `0x81 0x90`, not `0x82 0x00 0x90`.
    test('uses 0x81 long form for lengths 128-255', () {
      final value = Uint8List(0x90);
      final encoded = TlvUtils.encode([
        TLV(type: 5, length: value.length, value: value),
      ]);

      expect(encoded[0], 0x05);
      expect(encoded[1], 0x81);
      expect(encoded[2], 0x90);
      expect(encoded.length, 3 + 0x90);
    });

    test('uses 0x82 long form for lengths 256-65535', () {
      final value = Uint8List(300);
      final encoded = TlvUtils.encode([
        TLV(type: 6, length: value.length, value: value),
      ]);

      expect(encoded[0], 0x06);
      expect(encoded[1], 0x82);
      expect(encoded[2], 0x01); // 300 = 0x012C
      expect(encoded[3], 0x2C);
      expect(encoded.length, 4 + 300);
    });

    test('derives length from value, ignoring TLV.length', () {
      final encoded = TlvUtils.encode([
        TLV(type: 1, length: 99, value: Uint8List.fromList([0xAA, 0xBB])),
      ]);

      expect(encoded, equals([0x01, 0x02, 0xAA, 0xBB]));
    });
  });

  group('decode', () {
    test('decodes short-form entries with correct value length', () {
      final tlvList = TlvUtils.decode(Uint8List.fromList(
        [0x01, 0x03, 0x41, 0x42, 0x43, 0x02, 0x02, 0x44, 0x45],
      ));

      expect(tlvList.length, 2);
      expect(tlvList[0].type, 0x01);
      expect(tlvList[0].length, 3);
      expect(tlvList[0].value, equals([0x41, 0x42, 0x43]));
      expect(tlvList[1].type, 0x02);
      expect(tlvList[1].length, 2);
      expect(tlvList[1].value, equals([0x44, 0x45]));
    });

    test('decodes 0x81 long-form length', () {
      final value = List<int>.generate(0x90, (i) => i & 0xFF);
      final tlvList = TlvUtils.decode(
        Uint8List.fromList([0x05, 0x81, 0x90, ...value]),
      );

      expect(tlvList.single.type, 0x05);
      expect(tlvList.single.length, 0x90);
      expect(tlvList.single.value, equals(value));
    });

    test('throws on truncated value', () {
      expect(
        () => TlvUtils.decode(Uint8List.fromList([0x01, 0x05, 0x41])),
        throwsFormatException,
      );
    });

    test('throws on indefinite length form', () {
      expect(
        () => TlvUtils.decode(Uint8List.fromList([0x01, 0x80])),
        throwsFormatException,
      );
    });
  });

  group('round-trip', () {
    for (final size in [0, 1, 127, 128, 200, 255, 256, 1000, 65535]) {
      test('encode/decode preserves a $size-byte value', () {
        final value = Uint8List.fromList(
          List<int>.generate(size, (i) => i & 0xFF),
        );
        final tlv = TLV(type: 0x1F, length: value.length, value: value);

        final decoded = TlvUtils.decode(TlvUtils.encode([tlv]));

        expect(decoded.single, equals(tlv));
      });
    }
  });
}
