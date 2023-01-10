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
    List<int> data = [0x01, 0x03, 0x41, 0x42, 0x43, 0x02, 0x02, 0x44, 0x45];
    Uint8List bytes = Uint8List.fromList(data);
    List<TLV> tlvListDecoding = TlvUtils.decode(bytes);
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
