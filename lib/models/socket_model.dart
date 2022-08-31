class SocketApi {
  // A static private instance to access _socketApi from inside class only
  static final SocketApi _socketApi = SocketApi._internal();

  // An internal private constructor to access it for only once for static instance of class.
  SocketApi._internal();

  // Factry constructor to retutn same static instance everytime you create any object.
  factory SocketApi() {
    return _socketApi;
  }

  // All socket related functions.

}
