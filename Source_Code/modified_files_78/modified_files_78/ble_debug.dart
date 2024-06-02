import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../controller/ble_distance_controller.dart';
import 'ble_distance_info.dart';


class BleDeviceList extends StatefulWidget {
  const BleDeviceList({super.key});

  @override
  State<BleDeviceList> createState() => _BleDeviceListState();
}

class _BleDeviceListState extends State<BleDeviceList> {
  final BleScanner _scanner = BleScanner();
  final Set<ScanResult> _scanResults = {};
  bool showConnectableOnly = false;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    _scanner.startScanning((result) {
      setState(() {
        _scanResults.add(result);
      });
    });
  }

  void refreshDevices() async {
    setState(() {
      _scanResults.clear();
    });
    await _startScanning();
  }

  @override
  Widget build (BuildContext context ) {
    List <ScanResult> filteredScanResults = _scanResults.where((result) {
      return !showConnectableOnly || result.advertisementData.connectable;
    }).toList();

    List<ScanResult> sortedScanResults;
    if (filteredScanResults.isEmpty) {
      sortedScanResults = _scanResults.toList()
        ..sort((a, b) => b.rssi.compareTo(a.rssi));
    } else {
      sortedScanResults = filteredScanResults
        ..sort((a, b) => b.rssi.compareTo(a.rssi));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Devices'),
        actions: [
          IconButton(
            // <---- Refresh button
            onPressed: refreshDevices,
            icon: const Icon(CupertinoIcons.refresh_circled),
          ),
          IconButton( // Add a button to toggle the filter
            onPressed: () {
              setState(() {
                showConnectableOnly = !showConnectableOnly;
              });
            },
            icon: Icon(showConnectableOnly ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sortedScanResults.length,
        itemBuilder: (context, index) {
          final ScanResult result = sortedScanResults.toList()[index];
          final String deviceName = result.advertisementData.advName.isNotEmpty
              ? result.advertisementData.advName
              : 'Unknown';
          final String deviceId = result.device.remoteId.toString();
          final int rssi = result.rssi;
          final bool connectable = result.advertisementData.connectable;
          final bool hardCodedMACCheck = deviceId == 'D4:91:26:AA:E9:2D' ? true : false;
          final bool connected = result.device.isConnected;

          var childrenListTile = [
            Text('RSSI: $rssi dBm'),
            Text(
              'Connectable: $connectable',
              style: TextStyle(
                color: connectable ? Colors.lightGreen.shade400 : Colors.red.shade400,
              ),
            ),
            Text("Tx Power: ${result.advertisementData.txPowerLevel} dBm"),
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
                  text: '($deviceId) ',
                  style: TextStyle(
                    color: hardCodedMACCheck ? Colors.lightGreen.shade400 : Colors.red.shade400,
                  ),
                ),
                TextSpan(
                  text: connected ? "CONNECTED" : "",
                  style: TextStyle(
                    color: connected ? Colors.lightGreen.shade400 : Colors.black,
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
              child: GestureDetector(
                onTap: goToDeviceInfo,
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
              )

          );
        },
      ),
    );

  }

}