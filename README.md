## Donation

If this package helps you, consider supporting its development:

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://ko-fi.com/alnajjar)

---

# tlv_decoder

TLV stands for "Type-Length-Value," a data structure used to encapsulate multiple pieces of information into a single byte sequence.

## Features

* Encode a list of `TLV` entries into bytes.
* Decode bytes into a list of `TLV` entries.
* BER/DER length fields, both short and long form:
  * `0x00`–`0x7F` for lengths `0`–`127`.
  * `0x81 LL` for lengths `128`–`255`.
  * `0x82 LL LL` for lengths `256`–`65535`.
  * `0x83`/`0x84 …` for larger lengths.
* Input validation with clear `FormatException` messages for truncated or unsupported input.

## Getting started

```yaml
dependencies:
  tlv_decoder: ^0.0.5
```

## Usage

```dart
import 'dart:typed_data';

import 'package:tlv_decoder/tlv_decoder.dart';

void main() {
  // Decoding
  final data = Uint8List.fromList(
    [0x01, 0x03, 0x41, 0x42, 0x43, 0x02, 0x02, 0x44, 0x45],
  );
  final List<TLV> tlvList = TlvUtils.decode(data);

  // Encoding
  final encoded = TlvUtils.encode([
    TLV(type: 1, length: 3, value: Uint8List.fromList([0x41, 0x42, 0x43])),
    TLV(type: 2, length: 2, value: Uint8List.fromList([0x44, 0x45])),
  ]);
}
```

`TLV.length` is informational; `TlvUtils.encode` always derives the length field from the value bytes.

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/leithalnajjar/tlv_decoder/issues).

## License

Project under MIT [license](https://github.com/leithalnajjar/tlv_decoder/blob/master/LICENSE).
