## 0.0.5

* Fix length encoding for values of 128 octets or more (GitHub issue #1): lengths 128–255 now use the `0x81 LL` long form and larger lengths use `0x82`/`0x83`/`0x84` per BER/DER, instead of producing invalid bytes.
* Fix `decode` to report the value length in `TLV.length` (previously the length-field byte count).
* Add length-field validation with clear `FormatException` messages for truncated and indefinite-length input.
* Add `TLV.toString`, `==` and `hashCode`.
* Add API documentation and a full test suite.
* Support Dart 3 and update `flutter_lints`.

## 0.0.4

* Fix get bytes length.

## 0.0.3

* Change README.md.

## 0.0.2

* Add example.
* Fix import TLV model.

## 0.0.1

* Initial release.
