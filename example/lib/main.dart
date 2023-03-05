import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tlv_decoder/tlv_decoder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(title: 'TLV encoding and decoding'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key? key, this.title = ''}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _encode() {
    List<TLV> tlvListEncoding = [
      TLV(type: 1, length: 3, value: Uint8List.fromList([0x41, 0x42, 0x43])),
      TLV(type: 2, length: 2, value: Uint8List.fromList([0x44, 0x45]))
    ];
    Uint8List encodedData = TlvUtils.encode(tlvListEncoding);
  }

  _decode() {
    String dataBase64 = 'AYGlMWJhNDdmNjQtZjM0Zi00OGViLWIzYjQtY2IxMjA4ZDIwMTA1P2ludm9pY2UtbnVtYmVyPUVJTjI2NTczJnNlbGxlci1uYW1lPUQgRCBEIEQmdGF4LW51bWJlcj04MDA2Mzg1Jmludm9pY2UtaXNzdWUtZGF0ZT0yMDIzLTAyLTI3Jmludm9pY2UtdG90YWw9NTUuNjgwJnRheC10b3RhbD03LjY4AgJ7fQMFZmFsc2UEBjU1LjY4MAUIRUlOMjY1NzMGBDcuNjgHCjIwMjMtMDItMjcIBzgwMDYzODUJB0QgRCBEIEQQYE1FVUNJSFV0OURSOEViaDJnNVloMTRUTzJBb3ROWXljcm1yYncxOHVOaW9PVVhyOEFpRUE4WXdFUVdOVTlWSE5vaS93MUdwaFBSbktlUmpkelA4eWxYdmcrb2VJbDJjPQ==';
    List<int> data = [0x01, 0x03, 0x41, 0x42, 0x43, 0x02, 0x02, 0x44, 0x45];
    Uint8List bytes = Uint8List.fromList(data);
    List<TLV> tlvListDecoding = TlvUtils.decode(const Base64Decoder().convert(dataBase64));
    log('ana ${tlvListDecoding}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                _encode();
              },
              child: const Text('Encode'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                _decode();
              },
              child: const Text('Decode'),
            ),
          ],
        ),
      ),
    );
  }
}
