import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../../constants/url.dart';

Future<Map<String, dynamic>?> login(String phone, String password) async {
  Response response;

  try {
    response = await http.post(Uri.parse('$baseUrl/auth/login'),
        body: {"phone": phone, "password": password});

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
