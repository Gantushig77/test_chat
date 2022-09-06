import 'dart:convert';

import 'package:intl/intl.dart';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  ChatModel({
    this.id,
    this.room,
    this.sender,
    this.receiver,
    this.createdAt,
    this.message,
  });

  String? id;
  String? room;
  String? sender;
  String? receiver;
  DateTime? createdAt;
  String? message;

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    DateTime date = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(json["createdAt"]);
    return ChatModel(
      id: json["id"],
      room: json["room"],
      sender: json["sender"],
      receiver: json["receiver"],
      createdAt: date,
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "room": room,
        "sender": sender,
        "receiver": receiver,
        "createdAt": createdAt.toString(),
        "message": message,
      };
}
