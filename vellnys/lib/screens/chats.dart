import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vellnys/persistence.dart' as persistence;
import 'package:vellnys/screens/welcome.dart';
import 'package:vellnys/config.dart';

class ChatList extends StatefulWidget {
  final SharedPreferences prefs;

  const ChatList({Key? key, required this.prefs}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late String _firebaseUserId;
  late var _firebaseUser;
  late List<QueryDocumentSnapshot> _chatRooms;
  late var _otherChatUsers;

  int MAX_ALLOWED_CHATS = 3;
  late bool isAtLimit;

  // Firebase stuff
  var db = FirebaseFirestore.instance;

  _getLoggedInFirebaseUserId() async {
    var userId = persistence.firebaseUserId(widget.prefs);
    if (userId == null) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Welcome(),
        ),
      );
    }
    setState(() {
      _firebaseUserId = userId;
    });
  }

  _getFirebaseUser() async {
    var user = await db.collection('users').doc(_firebaseUserId).get();
    setState(() {
      _firebaseUser = user;
    });
  }

  _getChatRooms() async {
    var event = await db
        .collection("rooms")
        .where("members", whereIn: [_firebaseUser]).get();
    for (var room in event.docs) {
      var otherUser = room
          .data()['members']
          .firstWhere((element) => element != _firebaseUser.data()['id']);
      setState(() {
        _chatRooms.add(room);
        _otherChatUsers.add(otherUser);
      });
    }
  }

  _checkIsAtLimit() async {
    // 1. Check if the user is a premium user. If they are, set the limit to false
    // 2. If they are not a premium user, check if they have reached the limit
    // 3. If they have reached the limit, set the limit to true

    bool premium = _firebaseUser.data()['premium'];
    if (premium) {
      setState(() {
        isAtLimit = false;
      });
    } else {
      int numChats = _chatRooms.length;
      if (numChats >= MAX_ALLOWED_CHATS) {
        setState(() {
          isAtLimit = true;
        });
      } else {
        setState(() {
          isAtLimit = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getLoggedInFirebaseUserId();
    _getFirebaseUser();
    _getChatRooms();
    _checkIsAtLimit();
  }

  Widget _buildRow(index) {
    var chatRoom = _chatRooms[index].data() as Map<String, dynamic>;
    var otherUser = _otherChatUsers[index].data() as Map<String, dynamic>;
    return ListTile(
      title: Text(otherUser['name']),
      subtitle: Text(chatRoom['lastMessage']),
      leading:
          CircleAvatar(foregroundImage: NetworkImage(otherUser['photoUrl'])),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              prefs: widget.prefs,
              chatRoom: _chatRooms[index] as Map<String, dynamic>,
              otherUser: _otherChatUsers[index],
            ),
          ),
        );
      },
    );
  }

  _getNewChatFriend() async {
    // TODO: Make API request to get a new chat friend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your buddies'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                itemCount: _chatRooms.length,
                itemBuilder: (context, index) {
                  return _buildRow(index);
                },
              ),
              isAtLimit
                  ? primaryButton(
                      'Find new friend',
                    )
                  : Container(),
            ]),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatRoom;
  final DocumentSnapshot otherUser;
  final SharedPreferences prefs;

  const ChatScreen(
      {Key? key,
      required this.prefs,
      required this.chatRoom,
      required this.otherUser})
      : super(key: key);

  @override
  State<ChatScreen> createState({required}) => _ChatScreenState();
}

class Message {
  final bool isAudio;
  final String? contents;
  final String senderId;
  final Timestamp timestamp;

  Message(
      {this.contents,
      required this.isAudio,
      required this.senderId,
      required this.timestamp});

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      contents: map['contents'] ?? '',
      isAudio: map['isAudio'],
      senderId: map['senderId'],
      timestamp: map['timestamp'],
    );
  }

  toJson() {
    return {
      'isAudio': isAudio,
      'contents': contents,
      'senderId': senderId,
      'timestamp': timestamp,
    };
  }
}

class _ChatScreenState extends State<ChatScreen> {
  // Firebase
  FirebaseFirestore db = FirebaseFirestore.instance;
  late final _room = db.collection("rooms").doc(widget.chatRoom['id']);
  late final _roomMessageCollection = _room.collection("messages");
  late final _messageStream = _roomMessageCollection.snapshots();
  late final _otherUserData = widget.otherUser.data() as Map<String, dynamic>;

  // UI
  late List<Message> _messages;
  late List<Widget> _messageWidgets;

  bool _isRecording = false;

  late TextEditingController _controller;

  Widget _generateMessageWidget(Message message) {
    bool wasSentByMe =
        message.senderId == persistence.firebaseUserId(widget.prefs);
    bool isAudio = message.isAudio;

    return Column(
      children: [
        Align(
          alignment: wasSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: 32.0, minWidth: 300.0),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: wasSentByMe ? primaryColor : secondaryGray),
                  child: Text(message.contents!))),
        ),
        isAudio ? const SizedBox(height: 3.0) : Container(),
        isAudio
            ? Text('Transcribed audio',
                style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.w600))
            : Container(),
      ],
    );
  }

  _addMessageWidget(Message message) {
    setState(() {
      _messages.add(message);
      _messageWidgets.add(_generateMessageWidget(message));
    });
  }

  _addSnapshotListener() {
    _messageStream.listen((event) {
      final isPendingLocalUpload = (event.metadata.hasPendingWrites);
      if (isPendingLocalUpload) {
        return;
      }
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            // TODO: Make messagewidget and add
            final data = change.doc.data() as Map<String, dynamic>;
            final message = Message.fromMap(data);
            _addMessageWidget(message);
            break;
          case DocumentChangeType.modified:
            break;
          case DocumentChangeType.removed:
            break;
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _addSnapshotListener();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_otherUserData['name'],
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w800)),
              Text(
                  '${DateTime.now().difference(widget.chatRoom['timeOpened'].toDate()).inDays}D',
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.shade400)),
            ],
          ),
          leading: CircleAvatar(
              foregroundImage: NetworkImage(_otherUserData['photoUrl'])),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [_messagesColumn(), const Spacer(), _sendField()],
            ),
          ),
        ));
  }

  Widget _messagesColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: _messageWidgets.length,
            itemBuilder: (context, index) {
              return _messageWidgets[index];
            },
          ),
        ),
      ],
    );
  }

  Widget _textSendField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Type a message',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.5),
        ),
      ),
    );
  }

  Widget audioRecordingField() {
    return Container();
  }

  Widget _sendField() {
    return Row(
      children: [
        Expanded(
            child: _isRecording ? audioRecordingField() : _textSendField()),
        IconButton(
          disabledColor: Colors.blue.shade600,
          onPressed: _controller.text.isNotEmpty ? _handleSendPressed : null,
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }

  _handleUploadAudioRecording() {
    // TODO: Send the audio to the API
  }

  _handleSendPressed() {
    Message newMessage = Message(
        isAudio: false,
        timestamp: Timestamp.now(),
        contents: _controller.text,
        senderId: persistence.firebaseUserId(widget.prefs) ?? '');
    _roomMessageCollection.add(newMessage.toJson());
    _addMessageWidget(newMessage);
  }
}
