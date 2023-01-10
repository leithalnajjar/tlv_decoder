import 'dart:typed_data';
import 'package:tlv_decoder/src/model/tlv_model.dart';

class TlvUtils {
  static List<TLV> decode(Uint8List data) {
    var tlvList = <TLV>[];
    var offset = 0;
    while (offset < data.length) {
      // Read the type field (1 byte)
      var type = data[offset];
      offset += 1;

      // Read the length field (1 or 3 bytes)
      var length = data[offset];
      if ((length & 0x80) != 0) {
        // The length field is 3 bytes long
        var lengthBytes = data.sublist(offset, offset + 3);
        length = int.parse(lengthBytes.map((b) => b.toRadixString(16)).join(), radix: 16);
        offset += 3;
      } else {
        // The length field is 1 byte long
        offset += 1;
      }

      // Read the value field
      var value = data.sublist(offset, offset + length);
      offset += length;

      tlvList.add(TLV(type: type, length: length, value: value));
    }
    return tlvList;
  }

  static Uint8List encode(List<TLV> tlvList) {
    var data = Uint8List(0);
    for (TLV tlv in tlvList) {
      var value = tlv.value;
      var length = value.length;

      var typeBytes = Uint8List.fromList([tlv.type]);
      var lengthBytes = _encodeLength(length);
      var valueBytes = Uint8List.fromList(value);

      data = _concatUint8List([data, typeBytes, lengthBytes, valueBytes]);
    }
    return data;
  }

  static Uint8List _encodeLength(int length) {
    if (length < 128) {
      return Uint8List.fromList([length]);
    }
    var lengthBytes = Uint8List(3);
    lengthBytes[0] = 0x82;
    lengthBytes.setRange(1, 3, Uint8List.fromList([length]));
    return lengthBytes;
  }

  static Uint8List _concatUint8List(List<Uint8List> lists) {
    var totalLength = lists.map((list) => list.length).reduce((a, b) => a + b);
    var result = Uint8List(totalLength);
    var offset = 0;
    for (var list in lists) {
      result.setRange(offset, offset + list.length, list);
      offset += list.length;
    }
    return result;
  }
}
