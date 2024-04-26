import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleScanner {
  Future<Set<ScanResult>> startScanning(Function(ScanResult) onScanResult) async {
    final Set<ScanResult> scanResults = {};

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 4), 
      androidUsesFineLocation: true
    );

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      results.sort((a, b) => b.rssi.compareTo(a.rssi));
      // final filteredResults = results.where((result) =>
      //   result.advertisementData.serviceUuids.isNotEmpty &&
      //   result.advertisementData.connectable
      // );
      
      for (var result in results) {
      // Add each result to the scanResults set
      onScanResult(result); 
    }
  });

  // Stopping the scan after 4 seconds
  await Future.delayed(const Duration(seconds: 4));
  await FlutterBluePlus.stopScan();
  subscription.cancel(); // Cancel the subscription

  // print('Scan results: $scanResults');
  return scanResults;
}


  // Future<ScanResult?> scanForDevice(String deviceName, DeviceIdentifier identifier) async {
  //   await FlutterBluePlus.startScan(
  //       timeout: const Duration(seconds: 4), androidUsesFineLocation: true);
  //   ScanResult? scanResult;

  //   FlutterBluePlus.scanResults.listen((results) {
  //     final filteredResult = results.where((result) =>
  //         result.advertisementData.advName == deviceName
  //         && result.device.remoteId == identifier);
  //     scanResult = filteredResult.first;
  //   });

  //   return scanResult;
  // }

  Future<ScanResult?> scanForDevice(String deviceName, DeviceIdentifier identifier) async {
    // Start scanning for devices
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4), androidUsesFineLocation: true);

    // Create a Completer to handle asynchronous results
    final completer = Completer<ScanResult?>();

    // Listen for scan results
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      final filteredResults = results.where((result) =>
          result.advertisementData.advName == deviceName &&
          result.device.remoteId == identifier);
      
      if (filteredResults.isNotEmpty) {
        completer.complete(filteredResults.first);
        FlutterBluePlus.stopScan();
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      // If the Completer is not completed, it means the device is not found within the timeout
      if (!completer.isCompleted) {
        subscription.cancel();
        
        FlutterBluePlus.stopScan();
        
        // Complete the Completer with null to indicate that the device is not found
        completer.complete(null);
      }
    });

    return completer.future;
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      // Handle disconnection failure
      print('Failed to disconnect from device: $e');
    }
  }

  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
  }
}
