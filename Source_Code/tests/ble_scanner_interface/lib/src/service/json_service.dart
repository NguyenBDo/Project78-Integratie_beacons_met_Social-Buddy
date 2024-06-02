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