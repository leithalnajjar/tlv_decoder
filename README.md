TLV stands for "Type-Length-Value," and it is a data structure used to encapsulate multiple pieces of information into a single entity.

## Features

TLV encoding and decoding.

## Getting started

```yaml
dependencies:
  tlv_decoder: ^0.0.3
```

## Usage

A simple usage example:

```dart
import 'dart:typed_data';

import 'package:tlv_decoder/tlv_decoder.dart';

// Decoding
List<int> data = [0x01, 0x03, 0x41, 0x42, 0x43, 0x02, 0x02, 0x44, 0x45];
Uint8List bytes = Uint8List.fromList(data);
List<TLV> tlvList = TlvUtils.decode(bytes);

// Encoding
List<TLV> tlvList = [TLV(type: 1, length: 3, value: [0x41, 0x42, 0x43]), TLV(type: 2, length: 2, value: [0x44, 0x45])];
Uint8List encodedData = TlvUtils.encode(tlvList);
```
## Features and bugs

Please feel free for feature requests and bugs at the [issue tracker](https://github.com/leithalnajjar/tlv_decoder/issues).

## License

Project under MIT [license](https://github.com/leithalnajjar/tlv_decoder/blob/master/LICENSE).
