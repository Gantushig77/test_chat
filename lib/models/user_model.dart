class UserModel {
  UserModel({this.id, this.firstname, this.lastname, this.chatActive});

  String? id;
  String? firstname;
  String? lastname;
  bool? chatActive;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        firstname: json["firstname"],
        lastname: json["lastname"],
        chatActive: json["chatActive"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstname": firstname,
        "lastname": lastname,
        "chatActive": chatActive,
      };
}
