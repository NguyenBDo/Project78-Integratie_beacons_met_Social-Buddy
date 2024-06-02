import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

class JsonService {

  Future<Map> readJson({
    required String path,

  }) async {
    final response = await rootBundle.loadString(path);
    final data = await json.decode(response) as Map;

    return data;
  }

  Future<void> writeJson({
    required String path,
    required Map<String, dynamic> data
  }) async {
    final jsonContent = json.encode(data);
    await File(path).writeAsString(jsonContent);
  }
}

class ReconnectDataService {
  final JsonService _jsonService = JsonService();
  static const String _configFilePath = 'path_to_your_config_file.json';
  static const String _jsonObject = "auto_reconnect";

  Future<List<String>> getAutoReconnect() async {
    try {
      final config = await _jsonService.readJson(path: _configFilePath);
      return List<String>.from(config[_jsonObject] ?? []);
    } catch (e) {
      // Handle exceptions
      return [];
    }
  }

  Future<bool?> getDeviceReconnectionStatus(String device) async {
    try {
      final devices = await getAutoReconnect();
      return devices.contains(device);
    } catch (e) {
      // Handle exceptions
      return false;
    }
  }

  Future<void> setAutoReconnect(String deviceId, bool value) async {
    try {
      List<String> existingConfig = await getAutoReconnect();
      if (value && !existingConfig.contains(deviceId)) {
        existingConfig.add(deviceId);
      } else if (!value && existingConfig.contains(deviceId)) {
        existingConfig.remove(deviceId);
      }
      final config = {_jsonObject: existingConfig};
      await _jsonService.writeJson(path: _configFilePath, data: config);
    } catch (e) {
      // Handle exceptions
    }
  }

  Future<void> removeDevice(String device) async {
    try {
      final existingConfig = await getAutoReconnect();
      existingConfig.remove(device);
      final config = {_jsonObject: existingConfig};
      await _jsonService.writeJson(path: _configFilePath, data: config);
    } catch (e) {
      // Handle exceptions
    }
  }
}
