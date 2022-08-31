import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel user = UserModel();

  UserModel get getUser => user;

  getId() => user.id;
  getFirstname() => user.firstname;
  getLastname() => user.lastname;

  setUser(UserModel data) => {user = data, notifyListeners()};
}
