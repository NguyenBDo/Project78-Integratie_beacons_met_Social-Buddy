import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class BleScanner extends StatefulWidget {
  const BleScanner({super.key});

  @override
  State<BleScanner> createState() => _BleScannerState();
}

class _BleScannerState extends State<BleScanner> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<ScanResult> scanResults = [];
  Map<BluetoothDevice, bool> connectionStatus = {};

  // Temporary message variables
  String? temporaryMessage;
  Timer? messageTimer;

  @override
  void initState() {
    super.initState();
    disconnectAllDevices(); // Disconnect from all devices when the app starts
    startScanning();
  }

  void disconnectAllDevices() {
    // Disconnect from all connected devices
    for (var device in FlutterBluePlus.connectedDevices) {
      device.disconnect();
    }
  }

  void startScanning() async {
    await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4), androidUsesFineLocation: true);
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        results.sort((a, b) => b.rssi.compareTo(a.rssi));
        scanResults = results
            .where((result) =>
                result.advertisementData.serviceUuids.isNotEmpty 
                && result.advertisementData.connectable)
            .toList();
      });
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    // setState(() {
    //   connectionStatus[device] = true; // Set connecting state
    // });

    try {
      await device.connect();
      // Once connected, you can perform operations on the device.
      setState(() {
        connectionStatus[device] = true; // Reset connecting state
      });
      print("CONNECTED!");
    } catch (e) {
      setState(() {
        connectionStatus[device] = false; // Reset connecting state on error
      });
    }
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    await device.disconnect();
    setState(() {
      connectionStatus.remove(device); // Remove device from connection status map
    });
  }

  void showMessage(String message) {
    setState(() {
      temporaryMessage = message;
    });
    messageTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        temporaryMessage = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshDevices,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (context, index) {
          final result = scanResults[index];
          final device = result.device;
          final deviceName = result.advertisementData.advName.isEmpty ? 'Unknown' : result.advertisementData.advName;
          final isConnected = connectionStatus.containsKey(device);
          final deviceId = device.remoteId.toString();
          final rssi = result.rssi;
          final isTilePro = deviceId.contains('D4:91:26:AA:E9:2D');

          final childrenListTile = [
                Text('Device ID: $deviceId'),
                Text('Status: ${isConnected ? 'Connected' : 'Not Connected'}'),
                Text('RSSI: $rssi dBm'),
              ];

          return ListTile(
            title: Text(deviceName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: childrenListTile,
            ),
            tileColor: isTilePro ? Colors.green : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () { // ==>[] NAVIGATE TO BleDevice() Page
                    print("Bluetooth Connect");
                    if (connectionStatus[device] == null) {

                      connectToDevice(device);
                    } else {
                      const Text("Already Connected");
                    }
                    
                  }, 
                  icon: const Icon(Icons.bluetooth_connected_outlined)),
                
                IconButton(
                  onPressed: () { // ==>[] NAVIGATE TO BleDevice() Page
                    print("Bluetooth Disconnect");
                    if (connectionStatus[device] != null && connectionStatus[device]!) {

                      disconnectFromDevice(device);
                    } else {
                      const Text("Already Disconnected");
                    }
                    
                  }, 
                  icon: const Icon(Icons.bluetooth_disabled_sharp)),
              ],
            ),
          );
        },
      ),
      // bottomNavigationBar: temporaryMessage != null
      //     ? BottomAppBar(
      //         child: Container(
      //           alignment: Alignment.center,
      //           height: 50,
      //           color: Colors.black87,
      //           child: Text(
      //             temporaryMessage!,
      //             style: const TextStyle(color: Colors.white),
      //           ),
      //         ),
      //       )
      //     : null,
    );
  }

  void refreshDevices() async {
    await FlutterBluePlus.stopScan();
    setState(() {
      scanResults.clear();
    });
    // Restart scanning
    startScanning();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    messageTimer?.cancel(); // Cancel the message timer
    super.dispose();
  }
}


                  // ElevatedButton(
                  //   onPressed: isConnected
                  //       ? null
                  //       : () {
                  //           connectToDevice(device);
                  //         },
                  //   style: ButtonStyle(
                  //     backgroundColor: isConnected ? MaterialStateProperty.all(Colors.grey) : null,
                  //   ),
                  //   child: const Text('Connect'),
                  // ),
                  // const SizedBox(width: 10),
                  // ElevatedButton(
                  //   onPressed: !isConnected
                  //       ? () {
                  //           showMessage('The device is not connected');
                  //         }
                  //       : null,
                  //   style: ButtonStyle(
                  //     backgroundColor: !isConnected ? MaterialStateProperty.all(Colors.grey) : MaterialStateProperty.all(Colors.red),
                  //   ),
                  //   child: const Text('Disconnect'),
                  // ),