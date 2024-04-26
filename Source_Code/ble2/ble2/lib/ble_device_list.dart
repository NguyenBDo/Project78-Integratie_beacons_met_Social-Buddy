import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'dart:async';
import 'ble_scanner.dart';
import 'ble_device_info.dart';

class BleDeviceList extends StatefulWidget {
  const BleDeviceList({super.key});

  @override
  State<BleDeviceList> createState() => _BleDeviceListState();
}

class _BleDeviceListState extends State<BleDeviceList> {
  final BleScanner _scanner = BleScanner();
  final Set<ScanResult> _scanResults = {};

  @override
  void initState() {
    super.initState();
    _startScanning();
  }


  /// Start scanning for BLE devices
  Future<void> _startScanning() async {
     _scanner.startScanning((result) {
      setState(() {
        _scanResults.add(result);
      });
    });
  }

  /// Refresh the list of scanned devices, when the refresh button is pressed
  void refreshDevices() async {
    setState(() {
      _scanResults.clear();
    });
    await _startScanning();
  }
  
  @override
  Widget build(BuildContext context) {
    List<ScanResult> sortedScanResults = _scanResults.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi)); // Sort by RSSI in descending order

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Devices'),
        actions: [
          IconButton( // <---- Refresh button
            onPressed: refreshDevices,
            icon: const Icon(CupertinoIcons.refresh_circled),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _scanResults.length,
        itemBuilder: (context, index) {
          final ScanResult result = sortedScanResults.toList()[index];
          final String deviceName = result.advertisementData.advName.isNotEmpty
              ? result.advertisementData.advName
              : 'Unknown';
          final String deviceId = result.device.remoteId.toString();
          final int rssi = result.rssi;
          final bool connectable = result.advertisementData.connectable;
          final bool hardCodedMACCheck = deviceId == 'D4:91:26:AA:E9:2D' ? true : false;

          var childrenListTile = [
                // Text('Device ID: $deviceId', 
                //   style: TextStyle(
                //     color: hardCodedMACCheck ? Colors.lightGreen.shade400 : Colors.black
                //   ),
                // ),
                Text('RSSI: $rssi dBm'),
                Text('Connectable: $connectable', 
                  style: TextStyle(
                  color: connectable ? Colors.lightGreen.shade400 : Colors.red.shade400
                  ),
                ),
              ];
          
          var deviceTitle = RichText(
              text: TextSpan(
                text: '$deviceName: ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: '($deviceId)',
                    style: TextStyle(
                      color: hardCodedMACCheck ? Colors.lightGreen.shade400 : Colors.red.shade400
                    ),
                  ),
                ],
              ),
            );

          void goToDeviceInfo() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BleDeviceInfo(result: result),
              ),
            );
          }
          return Card(
          child: ListTile(
            title: deviceTitle,
            subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: childrenListTile,
            ),
            trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
              padding: const EdgeInsets.all(2.0),
              child: IconButton(
                onPressed: goToDeviceInfo,
                icon: const Icon(Icons.navigate_next_outlined),
                color: const Color.fromARGB(255, 87, 83, 83),
              ),
              ),
            ],
            ),
          ),
          );
        },
      ),
    );
  }
}
