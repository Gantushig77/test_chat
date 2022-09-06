import 'package:Chatlify/provider/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../components/loader.dart';
import '../models/chat_model.dart';
import '../provider/user_provider.dart';

class ChatScreen extends StatefulWidget {
  final String title;
  final String roomId;
  const ChatScreen({
    Key? key,
    required this.roomId,
    required this.title,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatModel> _messages = [];
  late Socket socket;

  Map<String, dynamic> room = {};
  int chatPage = 1;
  int pageLength = 1;
  bool loading = false;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    try {
      var socketProvider = Provider.of<SocketProvider>(context, listen: false);

      socket = socketProvider.getSocket();

      socket.emitWithAck('joinRoom', {'roomId': widget.roomId}, ack: (data) {
        List<ChatModel> messages = data['chat']['results']
            .map<ChatModel>((item) => ChatModel.fromJson(item))
            .toList();

        setState(() {
          pageLength = data['chat']['totalPages'];
          chatPage = data['chat']['page'];
          room = data['room'];
          _messages.addAll(messages);
        });
      });

      socket.on('message', (data) {
        var message = ChatModel.fromJson(data);
        setStateIfMounted(() {
          _messages.add(message);
        });
      });

      socket.onDisconnect((_) => debugPrint('chat page disconnect ...'));
    } catch (e) {
      print(e);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !loading) {
        debugPrint("Reached it's limit");
        if (chatPage < pageLength) {
          setState(() => loading = true);
          try {
            socket.emitWithAck(
                'getMessage', {'roomId': widget.roomId, 'page': chatPage + 1},
                ack: (data) {
              List<ChatModel> messages = data['chat']['results']
                  .map<ChatModel>((item) => ChatModel.fromJson(item))
                  .toList();

              setState(() {
                chatPage = data['chat']['page'];
                pageLength = data['chat']['totalPages'];
                _messages.insertAll(0, messages);
              });
            });
          } catch (e) {
            debugPrint(e.toString());
          }
          setState(() => loading = false);
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: const Color(0xFF271160),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFEAEFF2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    reverse: _messages.isEmpty ? false : true,
                    itemCount: 1,
                    shrinkWrap: false,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 10, left: 10, right: 10, bottom: 3),
                        child: Column(
                          mainAxisAlignment: _messages.isEmpty
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: <Widget>[
                            if (loading == true)
                              const Loader(
                                height: 100,
                                row: true,
                                progressHeight: 20,
                                progressWidth: 20,
                              ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _messages.map((message) {
                                  return ChatBubble(
                                    date: message.createdAt,
                                    message: message.message,
                                    isMe: message.sender == userProvider.getId(),
                                  );
                                }).toList()),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 10, left: 20, right: 10, top: 5),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        child: TextField(
                          minLines: 1,
                          maxLines: 5,
                          controller: _messageController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration.collapsed(
                            hintText: "Type a message",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 43,
                      width: 42,
                      child: FloatingActionButton(
                        backgroundColor: const Color(0xFF271160),
                        onPressed: () async {
                          if (_messageController.text.trim().isNotEmpty) {
                            String message = _messageController.text.trim();
                            String sender = userProvider.getId();
                            String receiver = room['users'][0] == sender
                                ? room['roomCreator']
                                : room['users'][0];

                            socket.emitWithAck(
                                "message",
                                {
                                  "room": widget.roomId,
                                  "sender": sender,
                                  "receiver": receiver,
                                  ...ChatModel(
                                          id: socket.id,
                                          room: room['id'],
                                          receiver: receiver,
                                          message: message,
                                          sender: sender,
                                          createdAt: DateTime.now())
                                      .toJson()
                                },
                                ack: (data) {});
                            _messageController.clear();
                          }
                        },
                        mini: true,
                        child: Transform.rotate(
                            angle: 5.79449, child: const Icon(Icons.send, size: 20)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String? message;
  final DateTime? date;

  ChatBubble({
    Key? key,
    this.message,
    this.isMe = true,
    this.date,
  });
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            constraints: BoxConstraints(maxWidth: size.width * .5),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE3D8FF) : const Color(0xFFFFFFFF),
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topRight: Radius.circular(11),
                      topLeft: Radius.circular(11),
                      bottomRight: Radius.circular(0),
                      bottomLeft: Radius.circular(11),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(11),
                      topLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                      bottomLeft: Radius.circular(0),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  message ?? '',
                  textAlign: TextAlign.start,
                  softWrap: true,
                  style: const TextStyle(color: Color(0xFF2E1963), fontSize: 14),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      date != null ? date.toString() : '',
                      textAlign: TextAlign.end,
                      style: const TextStyle(color: Color(0xFF594097), fontSize: 9),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
