import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:untitled/image_viewer.dart';

final _firestore = FirebaseFirestore.instance;
late User signedInUser;
String receiverUser = "";
String receivername = "";
String image = "";

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

String formattedTime = "";

class _MessagesState extends State<Messages> {
  final messageTextController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  String? messageTxt;

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        print("user email from messages :---> ${signedInUser.email}");
      }
    } catch (e) {
      print("from chat :- ${e}");
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Color customColor2 = Color.fromARGB(255, 216, 243, 248);
  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);
  Color myColor = Color(0xFF144C74);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    receiverUser = arguments?['email'] ?? '';
    receivername = arguments?['name'] ?? '';
    image = arguments?['image'] ?? '';

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: customColor),
        backgroundColor: mainColor,
        title: Row(
          children: [
            image == ""
                ? CircleAvatar(
                    backgroundColor: customColor,
                    backgroundImage: AssetImage("images/logo2.png"),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: mainColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: customColor,
                    backgroundImage: NetworkImage(image),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: mainColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
            SizedBox(width: 10),
            Text(
              "${receivername}",
              softWrap: true,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(width: 10),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.close_sharp),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/chat2.jpg"),
            fit: BoxFit.cover,
            opacity: 0.4,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MessageStreamBuilder(),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: mainColor,
                      width: 3,
                    ),
                  ),
                ),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_a_photo,
                            size: 25,
                            color: mainColor,
                          ),
                          onPressed: () async {
                            String? imageUrl = await _pickImage();
                            if (imageUrl != "") {
                              DateTime currentTime = DateTime.now();
                              formattedTime =
                                  DateFormat.jm().format(currentTime);
                              messageTextController.clear();
                              _firestore.collection('messages').add({
                                'receiver': receiverUser,
                                'text': "",
                                'imageUrl': imageUrl,
                                'sender': signedInUser.email,
                                'time': FieldValue.serverTimestamp(),
                                'timeSendMsg': formattedTime,
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageTextController,
                          onChanged: (value) {
                            messageTxt = value;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            hintText: 'Write your message here...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          DateTime currentTime = DateTime.now();
                          formattedTime = DateFormat.jm().format(currentTime);
                          messageTextController.clear();
                          _firestore.collection('messages').add({
                            'receiver': receiverUser,
                            'text': messageTxt,
                            'imageUrl': "",
                            'sender': signedInUser.email,
                            'time': FieldValue.serverTimestamp(),
                            'timeSendMsg': formattedTime,
                          });
                        },
                        child: Icon(
                          Icons.send_sharp,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Set<String> userPairs = Set<String>();

class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('time').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Text('Send the first message');
        }

        final messages = snapshot.data!.docs.reversed;

        List<MessageLine> messageWidgets = [];

        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          final messageReceiver = message.get('receiver');
          final imageUrl = message.get('imageUrl');
          final timeSendMsg = message.get("timeSendMsg");
          final currentUser = signedInUser.email;

          final messageWidget = MessageLine(
            sender: messageSender,
            text: messageText,
            receiver: messageReceiver,
            imageUrl: imageUrl,
            isMe: currentUser == messageSender,
            timeSendMsg: timeSendMsg,
          );

          if ((currentUser == messageSender &&
                  receiverUser == messageReceiver) ||
              (currentUser == messageReceiver &&
                  receiverUser == messageSender)) {
            userPairs.add('$messageSender-$messageReceiver');
            messageWidgets.add(messageWidget);
          }
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageLine extends StatelessWidget {
  const MessageLine({
    this.sender,
    this.text,
    this.imageUrl,
    required this.isMe,
    this.timeSendMsg,
    this.receiver,
    Key? key,
  }) : super(key: key);

  final String? sender;
  final String? text;
  final String? imageUrl;
  final bool isMe;
  final String? timeSendMsg;
  final String? receiver;

  @override
  Widget build(BuildContext context) {
    Color customColor = const Color(0xFFBBF1FA);
    Color mainColor = const Color(0xFF389AAB);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (imageUrl != "" && imageUrl != null)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewer(imageUrl: imageUrl!),
                  ),
                );
              },
              child: Image.network(
                "$imageUrl",
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          else
            Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
              elevation: 6,
              color: isMe ? mainColor : customColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  '$text',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isMe ? Colors.white : mainColor,
                  ),
                ),
              ),
            ),
          Text(
            "${timeSendMsg}",
            style: TextStyle(
              fontSize: 12,
              color: isMe
                  ? Color.fromARGB(255, 54, 148, 164)
                  : Color.fromARGB(255, 136, 134, 134),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> _pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final imageUrl = await _uploadImage(pickedFile.path);
    return imageUrl;
  } else {
    return "";
  }
}

Future<String> _uploadImage(String imagePath) async {
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  try {
    final ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images/$fileName.png');
    final uploadTask = ref.putFile(File(imagePath));

    await uploadTask.whenComplete(() => null);

    return await ref.getDownloadURL();
  } catch (e) {
    return "";
  }
}
