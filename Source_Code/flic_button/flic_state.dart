import 'package:buddy_bot/config/config_exporter.dart';
import 'package:buddy_bot/utils/common_method.dart';
import 'package:flutter/material.dart';
import 'package:flic_button/flic_button.dart';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';


class ButtonState extends ChangeNotifier {
  int _no = 0;
  bool _isScanning = false;
  FlicButtonPlugin? _flicButtonManager;
  final Map <String,  Flic2Button> _buttonsFound = {};
  Flic2ButtonClick? _lastClick;

  int get no => _no;
  bool get isScanning => _isScanning;
  Map <String, Flic2Button>  get buttonsFound => _buttonsFound;
  Flic2ButtonClick? get lastClick => _lastClick;
  // Getter for flicButtonManager
  FlicButtonPlugin? get flicButtonManager => _flicButtonManager;

  ButtonState() {
    _startStopFlic2();
  }


  void startStopFlic2() {
    if (_flicButtonManager == null) {
      _flicButtonManager = FlicButtonPlugin(flic2listener: _flicListener);
    } else {
      _flicButtonManager!.disposeFlic2().then((value) {
        _flicButtonManager = null;
        notifyListeners();
      });
    }

  }

  void _startStopFlic2() {
    if (_flicButtonManager == null) {
      _flicButtonManager = FlicButtonPlugin(flic2listener: _flicListener);
    } else {
      _flicButtonManager!.disposeFlic2().then((value) {
        _flicButtonManager = null;
      });
    }
  }

  void _startStopScanningForFlic2() async {
    if (!_isScanning) {
      final isGranted = await Permission.bluetooth.request().isGranted &&
          (!Platform.isAndroid ||
              (await Permission.bluetoothScan.request().isGranted &&
                  await Permission.bluetoothConnect.request().isGranted));
      if (!isGranted) {
        print('cannot scan for a button when scanning is not permitted');
      }
      if (Platform.isAndroid && !await Permission.location.isGranted) {
        await Permission.location.request();
      }
      _flicButtonManager?.scanForFlic2();
    } else {
      _flicButtonManager?.cancelScanForFlic2();
    }
    _isScanning = !_isScanning;
    notifyListeners();
  }

  void _getButtons() {
    _flicButtonManager?.getFlic2Buttons().then((buttons) {
      for (var button in buttons) {
        _addButtonAndListen(button);
      }
    });
  }

  void _addButtonAndListen(Flic2Button button) {
    _buttonsFound[button.uuid] = button;
    _flicButtonManager?.listenToFlic2Button(button.uuid);
    notifyListeners();
  }

  Future<void> _connectDisconnectButton(Flic2Button button) async {
    if (button.connectionState == Flic2ButtonConnectionState.disconnected) {
      if (!await Permission.bluetoothConnect.request().isGranted) {
        print(
            'cannot connect to a button when bluetooth connect is not permitted');
      }
      _flicButtonManager?.connectButton(button.uuid);
    } else {
      _flicButtonManager?.disconnectButton(button.uuid);
    }
  }

  void _forgetButton(Flic2Button button) {
    _flicButtonManager?.forgetButton(button.uuid).then((value) {
      if (value != null && value) {
        _buttonsFound.remove(button.uuid);
        notifyListeners();
      }
    });
  }

  void _handleButtonClick() {
    Map<String, dynamic> flic_fire =  {
      "name" : "flic send this message",
      "description" : "hello from flic",
      "email" : authController.firebaseUser!.email!,
      "startDate" : DateTime.now(),
      "endDate" : null,
      "type" : 2,
      "question" : false,
      "question_yes" : null,
      "question_no" : null,
      "repeat" : false,
      "addedDate" : DateTime.now(),
      "updatedDate" : null,
      "eventResponse" : null,
    };
    final refEvents = FirebaseFirestore.instance.collection('botUsers').doc(getVoucherData()!.voucherId).collection("Events").doc();
    flic_fire["id"] = refEvents.id;
    refEvents.set(flic_fire);
    notifyListeners();
  }

  Flic2Listener get _flicListener => _FlicListener(this);

  // Provide methods to access Flic button functionality from outside
  void startStopScanningForFlic2() => _startStopScanningForFlic2();
  void getButtons() => _getButtons();
  void connectDisconnectButton(Flic2Button button) =>
      _connectDisconnectButton(button);
  void forgetButton(Flic2Button button) => _forgetButton(button);

  @override
  void dispose() {
    _flicButtonManager?.disposeFlic2();
    super.dispose();
  }

}

class _FlicListener extends Flic2Listener {
  final ButtonState _buttonState;

  _FlicListener(this._buttonState);

  @override
  void onButtonClicked(Flic2ButtonClick buttonClick) {
    _buttonState._handleButtonClick();
  }

}

