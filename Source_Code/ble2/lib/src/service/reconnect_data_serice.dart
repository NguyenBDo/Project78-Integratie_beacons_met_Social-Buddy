import 'dart:io';
import 'dart:convert';

class ReconnectDataService{
   static final File _configFile = File('reconnect_data.json');

  static Future<Map<String, bool>> getAutoReconnect() async {
    try {
      if (!_configFile.existsSync()) return {};
      String content = await _configFile.readAsString();
      Map<String, dynamic> config = json.decode(content);
      return Map<String, bool>.from(config['autoReconnect'] ?? {});
    } catch (e) {
      // Handle exceptions
      return {};
    }
  }

  static Future<void> setAutoReconnect(String deviceId, bool value) async {
    try {
      Map<String, bool> existingConfig = await getAutoReconnect();
      existingConfig[deviceId] = value;
      Map<String, dynamic> config = {'autoReconnect': existingConfig};
      await _configFile.writeAsString(json.encode(config));
    } catch (e) {
      // Handle exceptions
    }
  }
}
