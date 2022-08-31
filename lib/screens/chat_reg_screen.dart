import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:socket_io_chat_client/models/user_model.dart';
import '../provider/user_provider.dart';
import 'chat_screen.dart';
import '../api/user.dart';
import '../constants/url.dart';
import '../components/snackbar_body.dart';

class RegScreen extends StatefulWidget {
  RegScreen({Key? key}) : super(key: key);

  @override
  _RegScreenState createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  TextEditingController _nameController = TextEditingController();
  bool loading = false;
  List users = [];
  late Socket socket;
  final box = Hive.box('testBox');

  void startChat() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        loading = true;
      });
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          loading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      username: _nameController.text.trim(),
                    )));
      });
    }
  }

  @override
  void initState() {
    setState(() {
      loading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = box.get('token')?['access_token'];

    try {
      socket = io(
          socketUrl,
          OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .enableReconnection()
              .setExtraHeaders({'Authorization': 'Bearer ${token}'})
              .setAuth({"Authorization": 'Bearer ${token}'})
              .build());

      socket.connect();

      socket.onConnect((_) {
        debugPrint('Connected ...');
        socket.emitWithAck('rooms', '{"msg":"requesting active users"}', ack: (data) {
          debugPrint('Emit with ack ...');
          if (data != null) {
            try {
              Map<String, dynamic> map = json.decode(data);
              print(map);
              setState(() {
                users = map['results'];
              });
            } catch (e) {
              debugPrint('could not convert to map');
              debugPrint(e.toString());
            }
          }
        });
      });

      socket.onDisconnect((_) {
        debugPrint('Disconnected ...');
        setState(() {
          users = [];
        });
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    profile().then((value) {
      userProvider.setUser(new UserModel(
        id: value?['id'],
        firstname: value?['firstname'],
        lastname: value?['lastname'],
      ));
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBarBody('Successfully logged in.', Colors.redAccent));
    });

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Container(
            height: size.height,
            width: size.width,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userProvider.user.firstname ?? 'firstname',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        userProvider.user.lastname ?? 'lastname',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(socket.active ? 'Online' : 'Offline'),
                  Text(socket.connected ? 'Connected' : 'Disconnected'),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        socket.connected ? socket.disconnect() : socket.connect();
                      },
                      child: Text(socket.connected ? 'Disconnect' : 'Connect')),
                  SizedBox(
                    height: 20,
                  ),
                  ...users
                      .map<Widget>((item) => Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    NetworkImage(item['swipePics'][0]['url']),
                              ),
                              title: Text('${item['firstname']} ${item['lastname']}'),
                              subtitle: Text('${item['id']} ${item['connectionId']}'),
                              isThreeLine: true,
                              onTap: () {
                                debugPrint(item['id']);
                              },
                            ),
                          ))
                      .toList()
                ],
              ),
            ),
          ),
          if (loading)
            Container(
              height: size.height,
              width: size.width,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
              child: Center(
                  child: SizedBox(
                      height: 50, width: 50, child: CircularProgressIndicator())),
            )
        ]),
      ),
    );
  }
}