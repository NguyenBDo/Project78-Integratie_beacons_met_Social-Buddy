import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleScanner {
  bool _isScanning = false;

  Future<Set<ScanResult>> startScanning(Function(ScanResult) onScanResult) async {
    if (_isScanning) return {}; // Return an empty set if already scanning
    final Set<ScanResult> scanResults = {};

    _isScanning = true;
    
  try {
    // Start the scan
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 4),
      androidUsesFineLocation: true,
    );

    // Listen for scan results
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      results.sort((a, b) => b.rssi.compareTo(a.rssi));
      for (var result in results) {
        // Add each result to the scanResults set
        onScanResult(result);
      }
    });

    // Delay for the scan duration
    await Future.delayed(const Duration(seconds: 4));

    // Stop the scan
    await FlutterBluePlus.stopScan();
    subscription.cancel(); // Cancel the subscription

    } catch (e) {   
      // Handle any exceptions, if necessary
      print('Error during scanning: $e');
    } finally {
      _isScanning = false; // Reset scanning flag
    }

    return scanResults;
  }

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
      // print('Failed to disconnect from device: $e');
    }
  }

  Future<void> stopScanning() async {
    if (!_isScanning) return;
    await FlutterBluePlus.stopScan();
  }
}
