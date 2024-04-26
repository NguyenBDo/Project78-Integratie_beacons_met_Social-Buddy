import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class BleDeviceInfo extends StatefulWidget {
  const BleDeviceInfo({super.key, required this.result});

  final ScanResult result;

  @override
  State<BleDeviceInfo> createState() => _BleDeviceInfoState();
}

class _BleDeviceInfoState extends State<BleDeviceInfo> {

  bool isConnected = false;
  bool isConnecting = false;
  List<String> serviceUuids = [];

  @override
  void initState() {
    super.initState();
    initDevice();
  }

  void initDevice() {
    final ScanResult result = widget.result;
    serviceUuids = result.advertisementData.serviceUuids
        .map((guid) => guid.toString())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Info'),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    final ScanResult result = widget.result;
    final String deviceName = result.advertisementData.advName.isNotEmpty
        ? result.advertisementData.advName
        : 'Unknown';
    final String deviceId = result.device.remoteId.toString();
    final String uuids = result.advertisementData.serviceData.toString();

    final scaledValueWidth = MediaQuery.of(context).size.width * 0.04; //Scaling value with width of the screen

    setState(() { // Check if the device is already connected
      final List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
      for (var dev in devs) {
        if (result.device.remoteId.toString() == dev.remoteId.toString()) {
          isConnected = true;
          break;
        }
      }
    });

    final List<SizedBox> textBoxes = [
      SizedBox( //0
          width: MediaQuery.of(context).size.width,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Device Name: $deviceName', 
                    style: TextStyle(fontSize: scaledValueWidth),
                    textAlign: TextAlign.left,
                  ),
            ),
          ),
        ),

      SizedBox( //1
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('RSSI: ${result.rssi} dBm', 
                  style: TextStyle(fontSize: scaledValueWidth),
                  textAlign: TextAlign.left,
                ),
          ),
        ),
      ),

      SizedBox( //2
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Connectable: ${result.advertisementData.connectable}', 
                  style: TextStyle(fontSize: scaledValueWidth),
                  textAlign: TextAlign.left,
                ),
          ),
        ),
      ),

      SizedBox( //3
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Device ID: $deviceId', 
                  style: TextStyle(fontSize: scaledValueWidth),
                  textAlign: TextAlign.left,
                ),
          ),
        ),
      ),

      SizedBox( //4
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('UUIDs: $uuids',
                  style: TextStyle(fontSize: scaledValueWidth),
                  textAlign: TextAlign.left,
                ),
          ),
        ),
      ),

      SizedBox( //5
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                text: 'Status: ',
                style: TextStyle(fontSize: scaledValueWidth, color: Colors.black),
                children: [
                  TextSpan(
                    text: isConnected ? 'Connected' : isConnecting ? 'Connecting...' : 'Disconnected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isConnected ? Colors.green : isConnecting ? Colors.orange : Colors.red,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    ];

    /// Connect/Disconnect button
    final ElevatedButton connectButton = ElevatedButton(
      onPressed: () {
        if (isConnecting) return;

        if (isConnected) {
          disconnectFromDevice();
        } else {
          connectToDevice();
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isConnected ? Colors.red : isConnecting ? Colors.grey : Colors.green,
        ),
      ),
      child: Text(
        isConnected
            ? 'Disconnect'
            : isConnecting
                ? 'Connecting...'
                : 'Connect',
        style: TextStyle(fontSize: scaledValueWidth, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );

    return SingleChildScrollView( // Wrap with SingleChildScrollView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...textBoxes,
          
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [connectButton]
          ),
        ],
      ),
    );
  }

  Future<void> connectToDevice() async {
    setState(() {
      isConnecting = true;
      isConnected = false;
    });
    try {
      await widget.result.device.connect();
      setState(() {
        isConnecting = false;
        isConnected = true;
      });
    } catch (e) {
      setState(() {
        isConnecting = false;
        isConnected = false;
      });
      // Handle connection error
    }
  }

  Future<void> disconnectFromDevice() async {
    await widget.result.device.disconnect();
    setState(() {
      isConnecting = false;
      isConnected = false;
    });
    
  }
}
