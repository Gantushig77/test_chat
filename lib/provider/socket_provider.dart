import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketProvider extends ChangeNotifier {
  late Socket socket;

  getSocket() => socket;

  setSocket(socket) {
    this.socket = socket;
    notifyListeners();
  }
}
