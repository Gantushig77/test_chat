import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
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
  bool loading = false;
  List rooms = [];
  late Socket socket;
  final box = Hive.box('testBox');

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
        socket.emitWithAck('rooms', '{"msg":"requesting room info"}', ack: (data) {
          debugPrint('Emit with ack ...');
          if (data != null) {
            try {
              Map<String, dynamic> map = json.decode(data);
              debugPrint('Successfully got rooms data');
              debugPrint(map.toString());
              setState(() {
                rooms = map['results'];
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
          rooms = [];
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Container(
          height: size.height,
          width: size.width,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 80),
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
                Container(
                  // height: MediaQuery.of(context).size.height - 278,
                  child: SingleChildScrollView(
                    child: Column(
                      children: rooms.map<Widget>((item) {
                        final user = userProvider.getId() == item['users'][0]['id']
                            ? item['roomCreator']
                            : item['users'][0];

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(user['swipePics'][0]['url']),
                            ),
                            title: Text('${user['firstname']} ${user['lastname']}'),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text('User ID : ${user['id']}'),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Socket ID : ${user['connectionId']}'),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Room ID : ${item['id']}'),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                        title: user['firstname'] ?? 'Chat',
                                        socket: socket,
                                        roomId: item['id'],
                                      )));
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
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
                child:
                    SizedBox(height: 50, width: 50, child: CircularProgressIndicator())),
          )
      ]),
    );
  }
}
