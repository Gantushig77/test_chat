import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../constants/url.dart';

class SocketProvider extends ChangeNotifier {
  final String token = Hive.box('testBox').get('token')?['access_token'];
  Socket socket(token) {
    if (!token) throw new Exception('Token must be present!');
    return io(
        socketUrl,
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableReconnection()
            .setExtraHeaders({'Authorization': 'Bearer ${token}'})
            .setAuth({"Authorization": 'Bearer ${token}'})
            .build());
  }

  Socket get getSocket => socket(token);
}
