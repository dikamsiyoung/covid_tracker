import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class JsonHelper {
  static Map<String, dynamic> jsonErrors;

  static void parseJsonFromAssets(
      String assetsPath) async {
    print('--- Parse json from: $assetsPath');
    final extractedData = await rootBundle.loadString(assetsPath);
    jsonErrors = json.decode(extractedData);
  }
}
