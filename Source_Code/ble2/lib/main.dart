import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'dart:async';

import 'src/ble/ble_device_list.dart';
import 'src/ble/first_scanner.dart';


void main() {
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // debug banner toggle
      title: "BLE connection application",
      home: BleDeviceList(),
      // home: BleScanner()
    );
  }
}