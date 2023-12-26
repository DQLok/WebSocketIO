import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  IO.Socket socket = IO.io("http://192.168.1.48:3001", <String, dynamic>{
    "transports": ["websocket"],
    "autoConnect": false
  });
  TextEditingController messageController = TextEditingController();
  List<String> messages = [];
  String jwt = "";

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io("http://192.168.1.48:3001", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    //connect
    try {
      socket.connect();
      socket.onConnect((_) {
        print('connect');
        socket.emit('hello', 'Hello, Server! I am Mobile');
      });
    } catch (e) {
      print(e);
    }
    socket.on('response', (data) {
      setState(() {
        messages.add(data);
      });
    });

    //chat mantual
    socket.on('chat_message', (data) {
      setState(() {
        messages.add(data['msg']);
      });
    });

    //login
    socket.on('login_jwt', (data) {
      setState(() {
        jwt = data;
      });
    });
  }

  sendMessage() {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      socket.emit('chat_message', {"jwt": jwt, "msg": message});
      messageController.clear();
    }
  }

  loginServer() {
    socket.connect();
    socket.emit('login_jwt', 'jwt');
  }

  receivecMsgServer() {
    //auto - jwt
    socket.emit('msg_auto', jwt);
    socket.on('msg_auto', (data) {
      setState(() {
        messages.add(data.toString());
      });
    });
  }

  disconnectServer() {
    socket.emit('disconnect', 'disconnect');
    socket.on('disconnect', (data) {
      setState(() {
        messages.add(data.toString());
        jwt = "";
      });
    });
    socket.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Socket.IO Chat'),
      ),
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: loginServer,
                icon: Icon(Icons.login),
                label: Text("login"),
              ),
              TextButton.icon(
                onPressed: receivecMsgServer,
                icon: Icon(Icons.add_to_home_screen_rounded),
                label: Text("auto receive"),
              ),
              TextButton.icon(
                onPressed: disconnectServer,
                icon: Icon(Icons.do_not_disturb_on_total_silence_sharp),
                label: Text("disconnect"),
              ),
            ],
          ),
          Text(jwt.isNotEmpty ? "Login Success: $jwt" : ""),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}
