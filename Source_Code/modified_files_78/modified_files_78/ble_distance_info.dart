import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:math';

import '../controller/ble_distance/ble_service.dart';

class BleDeviceInfo extends StatefulWidget {
  const BleDeviceInfo({Key? key, required this.result}) : super(key: key);

  final ScanResult result;


  @override
  State<BleDeviceInfo> createState() => _BleDeviceInfoState();
}

class _BleDeviceInfoState extends State<BleDeviceInfo> {
  bool isConnected = false;
  bool isConnecting = false;
  List<String> serviceUuids = [];
  bool doReconnect = false;
  int rssiAdaptive = 0;
  int previousRssi = -10000;
  int reconnectAttempts = 0;
  final int maxReconnectAttempts = 3;
  double distanceValue = 0.0;
  bool isDisconnectedHandled = false;
  final int TX_POWER = -53;
  final double N_VALUE = 3.3;


  ReconnectDataService reconnectDataService = ReconnectDataService();

  @override
  void initState() {
    super.initState();
    initDevice();
    _retrieveAutoReconnectStatus();
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

    final scaledValueWidth =
        MediaQuery.of(context).size.width * 0.04; //Scaling value with width

    setState(() {
      final List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
      for (var dev in devs) {
        if (result.device.remoteId.toString() == dev.remoteId.toString()) {
          isConnected = true;
          break;
        }
      }
    });



    final List<SizedBox> textBoxes = [
      SizedBox( // <---- Device Name
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Device Name: $deviceName',
              style: TextStyle(fontSize: scaledValueWidth),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      SizedBox( // <---- RSSI
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'RSSI: ${widget.result.device.isConnected ? rssiAdaptive : widget.result.rssi} dBm',
              style: TextStyle(fontSize: scaledValueWidth),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      SizedBox( // <---- Connectable
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Connectable: ${result.advertisementData.connectable}',
              style: TextStyle(fontSize: scaledValueWidth),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      SizedBox( // <---- Device ID
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Device ID: $deviceId',
              style: TextStyle(fontSize: scaledValueWidth),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      SizedBox( // <---- UUIDs
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'UUIDs: $uuids',
              style: TextStyle(fontSize: scaledValueWidth),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      SizedBox( // <---- Connection Status
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
                    text: isConnected
                        ? 'Connected'
                        : isConnecting
                        ? 'Connecting...'
                        : 'Disconnected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isConnected
                          ? Colors.green
                          : isConnecting
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      SizedBox( // <---- Distance
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Distance: ${widget.result.device.isConnected ? "[C]${distance(rssiAdaptive, TX_POWER, N_VALUE)}" : "[NC]${distance(rssiAdaptive, TX_POWER, N_VALUE)}"}',
              style: TextStyle(fontSize: scaledValueWidth),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    ];

    // -- connect button -- \\
    final ElevatedButton connectButton = ElevatedButton(
      onPressed: () {
        if (isConnecting || !widget.result.advertisementData.connectable) return;

        if (isConnected) {
          disconnectFromDevice();
        } else {
          connectToDevice();
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          !widget.result.advertisementData.connectable
              ? Colors.grey
              : isConnected
              ? Colors.red
              : isConnecting
              ? Colors.orange
              : Colors.green,
        ),
      ),
      child: Text(
        !widget.result.advertisementData.connectable
            ? 'Non-Connectable'
            : isConnected
            ? 'Disconnect'
            : isConnecting
            ? 'Connecting...'
            : 'Connect',
        style: TextStyle(fontSize: scaledValueWidth, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );

    // -- auto-reconnect button -- \\
    final ElevatedButton autoReconnectButton = ElevatedButton(
      onPressed: () {
        if (!widget.result.advertisementData.connectable) return;


        setState(() {
          doReconnect = !doReconnect;
        });

        if (doReconnect) {
          reconnectDataService.setAutoReconnect(deviceId, true);
        }
        else {
          reconnectDataService.setAutoReconnect(deviceId, false);
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          !widget.result.advertisementData.connectable
              ? Colors.grey
              : doReconnect
              ? Colors.blue
              : Colors.grey,
        ),
      ),
      child: Text(
        'Auto-Reconnect ${!widget.result.advertisementData.connectable ? 'UNAVAILABLE' : doReconnect ? 'ON' : 'OFF'}',
        style: TextStyle(fontSize: scaledValueWidth, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...textBoxes,
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              connectButton,
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              autoReconnectButton,
            ],
          ),
        ],
      ),
    );
  }

  void _retrieveAutoReconnectStatus() async {
    // Retrieve the auto-reconnect status from ReconnectDataService
    bool? reconnectStatus =
    await reconnectDataService.getDeviceReconnectionStatus(widget.result.device.remoteId.toString());
    if (reconnectStatus != null) {
      // Update the state of doReconnect based on the retrieved status
      setState(() {
        doReconnect = reconnectStatus;
      });
    }
  }

  // |-----------------------| \\
  // | connect to BLE device | \\
  // |-----------------------| \\
  Future<void> connectToDevice() async {
    if (!mounted || isConnecting || isConnected) return;

    setState(() {
      isConnecting = true;
      isConnected = false;
    });

    try {
      // Attempt to connect to the device
      await _connectWithRetries();

      final int rssi = await widget.result.device.readRssi();

      // If the connection is successful, update UI and handle disconnections
      setState(() {
        isConnecting = false;
        isConnected = true;
        rssiAdaptive = rssi;
        distanceValue = distance(rssiAdaptive, TX_POWER, N_VALUE);
        isDisconnectedHandled = false;
      });

      // Listen for disconnection events
      _listenForDisconnection();
    } catch (e) {
      // Handle connection failures
      if (!mounted) return;
      setState(() {
        isConnecting = false;
        isConnected = false;
      });
      // Implement retry logic or notify the user about connection failures
      // You can use Snackbars or Dialogs to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection failed. Please try again.'),
        ),
      );
    }
  }
  // |---------------------------------------| \\
  // | connection to BLE device with retries | \\
  // |---------------------------------------| \\
  Future<void> _connectWithRetries() async {
    for (int attempt = 1; attempt <= maxReconnectAttempts; attempt++) {
      try {
        if (doReconnect && attempt > 1) {
          // Exponential backoff for retry attempts
          await Future.delayed(Duration(seconds: attempt * 2));
        }

        // Attempt to connect to the device
        if (doReconnect) {
          await widget.result.device.connect(autoConnect: true, mtu: null);
        } else {
          await widget.result.device.connect();
        }

        // Wait for the connection to be established
        await widget.result.device.connectionState
            .where((val) => val == BluetoothConnectionState.connected)
            .first;

        // If using Android, request MTU
        if (Platform.isAndroid) {
          await widget.result.device.requestMtu(23);
        }

        // Reset reconnect attempts if connection is successful
        reconnectAttempts = 0;
        return;
      } catch (e) {
        // Log or handle connection failures
        print('Connection attempt $attempt failed: $e');
      }
    }
    // If all retry attempts fail, throw an error or handle as needed
    throw Exception('Failed to connect after $maxReconnectAttempts attempts');
  }

  // |-------------------------------| \\
  // | listening for a disconnection | \\
  // |-------------------------------| \\
  void _listenForDisconnection() {
    widget.result.device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _handleDisconnection();
      }
    });
  }

  // |------------------------| \\
  // | disconnect from device | \\
  // |------------------------| \\
  Future<void> disconnectFromDevice() async {
    if (!isConnected) return;
    await widget.result.device.disconnect();
    setState(() {
      isConnecting = false;
      isConnected = false;
    });
    _handleDisconnection();
  }

  // |----------------------| \\
  // | handle disconnection | \\
  // |----------------------| \\
  void _handleDisconnection() {
    if (!mounted || !isConnected || isDisconnectedHandled) return;
    setState(() {
      isConnecting = false;
      isConnected = false;
    });
    isDisconnectedHandled = true;
    print("Disconnected: ${widget.result.device.disconnectReason!.code} ${widget.result.device.disconnectReason!.description}");
  }

  // |----------------------| \\
  // | distance calculation | \\
  // |----------------------| \\
  /// calculate distance from RSSI and TX Power, by Khizer
  double distance(int rssi, int txPower, double N) {
    // print('$rssi, $txPower');
    double result = pow( 10.0, ( (txPower - rssi) / (10.0 * N) ) ).toDouble();
    // print(result);
    return result;
  }
}