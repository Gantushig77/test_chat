import 'package:flutter/material.dart';

SnackBar snackBarBody(String text, Color backColor) {
  return SnackBar(
    backgroundColor: backColor,
    content: Text(text),
  );
}
