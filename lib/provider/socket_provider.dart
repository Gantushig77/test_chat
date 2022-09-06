import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketProvider extends ChangeNotifier {
  final String token = Hive.box('testBox').get('token')?['access_token'];
  late Socket socket;

  setSocket(socket) {
    this.socket = socket;
    notifyListeners();
  }
}
