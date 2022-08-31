import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../../constants/url.dart';

Future<Map<String, dynamic>?> profile() async {
  Response response;
  var box = Hive.box('testBox');
  var token = box.get('token')?['access_token'];

  if (token == null || token.toString().isEmpty)
    throw new Exception('Authorization failed.');

  try {
    response = await http.get(Uri.parse('$baseUrl/user/profile'),
        headers: {'Authorization': 'Bearer ${token}'});

    if (response.statusCode != 200) {
      debugPrint("error in login ");
      throw Exception(json.decode(response.body));
    }

    Map<String, dynamic> map = json.decode(response.body);

    return map;
  } catch (e) {
    debugPrint("error has occured in login");
    debugPrint(e.toString());
    rethrow;
  }
}
