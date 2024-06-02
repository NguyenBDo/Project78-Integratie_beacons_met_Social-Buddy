import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:math';
import '../controller/ble_distance_controller.dart';


double distance(int rssi, int txPower, double N) {
  // print('$rssi, $txPower');
  double result = pow( 10.0, ( (txPower - rssi) / (10.0 * N) ) ).toDouble();
  // print(result);
  return result;
}

class BleTag extends StatefulWidget {
  const BleTag({super.key});

  @override
  State<BleTag> createState() => _BleTagState();

}

class _BleTagState extends State<BleTag> {
  static const String targetID = "D4:91:26:AA:E9:2D" ;// Tag id
  final BleScanner _scanner = BleScanner();
  ScanResult? _scanResult;
  Set<ScanResult> results = {};
  int rssi = 0;
  int previousRssi = -1000;
  final int txPower = -53; // Proto Distance Calc Values
  final double n = 3.3;
  String deviceID = "Not in range";
  int debugCount = 0;

  ScanResult? altDevice;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    _scanner.startScanning((result){

      if (result.device.remoteId.toString() == "D4:91:26:AA:E9:2D") {

        setState(() {
          _scanResult = result;
          previousRssi = rssi;
          deviceID = result.device.remoteId.toString();
        });

      } else {
        setState(() {
          results.add(result);
        });
      }
    });
  }

  void refresh() async {
    setState(() {
      _scanResult = null;
      rssi = previousRssi;
    });
    await _startScanning();

  }

  void reScan(List <ScanResult> scanResultList) async {
    FlutterBluePlus.onScanResults.listen((results){
      debugPrint(results.toString());

      setState(() {
        debugCount ++;
      });

      if (results.last.device.remoteId.toString() == targetID) {
        setState(() {
          deviceID = results.last.device.remoteId.toString();
          rssi = results.last.rssi;
        });

      }

      if (results.isNotEmpty) {
        scanResultList = results.toList()
          ..sort((a, b) => b.rssi.compareTo(a.rssi));

        if (altDevice == null){
          setState(() {
            altDevice = scanResultList.first;
          });
        }

      }

      debugPrint("times scanned $debugCount");
    },
        onError: (e) => debugPrint(e));
  }

  @override
  Widget build (BuildContext context) {

    List <ScanResult> sortedScanResults = [];

    FlutterBluePlus.onScanResults.listen((results){
      debugPrint(results.toString());

      setState(() {
        debugCount ++;
      });

      if (results.last.device.remoteId.toString() == targetID) {
        setState(() {
          deviceID = results.last.device.remoteId.toString();
          rssi = results.last.rssi;
        });

      }

      if (results.isNotEmpty) {
        sortedScanResults = results.toList()
          ..sort((a, b) => b.rssi.compareTo(a.rssi));

        if (altDevice == null){
          setState(() {
            altDevice = sortedScanResults.first;
          });
        }

      }

      debugPrint("times scanned $debugCount");
    },
        onError: (e) => debugPrint(e),
        onDone: () async => reScan(sortedScanResults)
    );


    if ( _scanResult == null ) {
      rssi = previousRssi;
    }

    final scaledValueWidth = MediaQuery.of(context).size.width* 0.05;

    final rangeColor = rssi <  -80 ?
    Colors.teal : Colors.red;

    final status1 = rssi < -90 ?
        "Beyond the boundary" : "Within the bounds";

    final estDistance = distance(rssi, txPower, n );

    List<SizedBox> bleData = [
      SizedBox(
          child: Card (
              color: rangeColor,

              child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text (
                    'Device: $deviceID' +
                    '\n RSSI Value: $rssi' +
                    '\n Estimated Distance: $estDistance' +
                    '\n status: $status1',
                    style: TextStyle(fontSize: scaledValueWidth),
                    textAlign: TextAlign.center,
                  ),
              )
          )
      ),

    ];

    if (results.isNotEmpty) {
      final closestResult = results.first;
      final closestRangeColor = closestResult.rssi < -80 ?
      Colors.teal : Colors.red;

      bleData.add(
        SizedBox (
            child: Card (
                color: closestRangeColor,
                child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text (
                      'Closest Distance: ${closestResult.rssi},'+
                          '\n Device: ${closestResult.device.remoteId}',
                      style: TextStyle(fontSize: scaledValueWidth),
                      textAlign: TextAlign.center,
                    )
                )
            )
        ),
      );

      if (altDevice != null) {
        bleData.add (
            SizedBox (
                child: Card (
                    color: Colors.blueGrey,
                    child: Padding (
                        padding: const EdgeInsets.all(2),
                        child: Text (
                            'Closest Distance ${altDevice?.rssi}' +
                                '\n Device : ${altDevice?.device.remoteId}'

                        )
                    )
                )
            )
        );
      }
    }

    return Scaffold (
      appBar: AppBar(
        title: const Text('BLE Range Demo'),
        actions: [
          IconButton(
            onPressed: refresh,
            icon: const Icon(CupertinoIcons.refresh_circled),)
        ],
      ),
      body: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        children: bleData
      ),
    );
  }
}
