import 'dart:convert';

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
  String? createdAt;
  String? message;

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        id: json["id"],
        room: json["room"],
        sender: json["sender"],
        receiver: json["receiver"],
        createdAt: json["createdAt"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "room": room,
        "sender": sender,
        "receiver": receiver,
        "createdAt": createdAt,
        "message": message,
      };
}
