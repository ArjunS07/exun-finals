import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loqui/persistence.dart' as persistence;
import 'package:loqui/screens/welcome.dart';
import 'package:loqui/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:record/record.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:uuid/uuid.dart';

class ChatList extends StatefulWidget {
  final SharedPreferences prefs;

  const ChatList({Key? key, required this.prefs}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final users = FirebaseFirestore.instance.collection('users');
  final chats = FirebaseFirestore.instance.collection('rooms');

  var otherUsers = [];
  var activeChats = [];

  var isLoading;

  // audio

  @override
  void initState() {
    // TODO: implement initState
    _getChats();

    super.initState();
  }

  void _getChats() {
    String id = persistence.firebaseUserId(widget.prefs)!;
    chats
        .where('members',
            arrayContains: persistence.firebaseUserId(widget.prefs))
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            var data = change.doc.data();
            data!['id'] = change.doc.id;
            var members = data['members'];
            var otherUserId = members.firstWhere((element) => element != id);
            var otherUser =
                users.doc(otherUserId).get().then((DocumentSnapshot userDoc) {
              if (userDoc.exists) {
                setState(() {
                  otherUsers.add(userDoc.data() as Map<String, dynamic>);
                });
              }
            });

            activeChats.add(data);
            break;
          case DocumentChangeType.removed:
            setState(() {
              otherUsers
                  .removeWhere((element) => element['id'] == change.doc.id);
              activeChats
                  .removeWhere((element) => element['id'] == change.doc.id);
            });
            break;
          case DocumentChangeType.modified:
            activeChats
                .removeWhere((element) => element['id'] == change.doc.id);
            activeChats.add(change.doc.data() as Map<String, dynamic>);
        }
      }
    });
  }

  Widget _buildRow(index) {
    var otherUser = otherUsers[index];
    var chat = activeChats[index];
    return ListTile(
      title: Text(otherUser['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
      subtitle: Text(chat['lastMessage']),
      trailing: const Icon(Icons.arrow_forward_ios),
      // leading:
      //     CircleAvatar(foregroundImage: NetworkImage(otherUser['photoUrl'])),
      onTap: () {
        print(chat as Map<String, dynamic>);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              prefs: widget.prefs,
              chatRoom: chat as Map<String, dynamic>,
              otherUser: otherUser as Map<String, dynamic>,
            ),
          ),
        );
      },
    );
  }

  _getNewChatFriend() async {
    print('Making request...');
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://localhost:4996/match-user'));
    String firebaseId = persistence.firebaseUserId(widget.prefs)!;
    request.fields.addAll({'user_id': firebaseId});

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Your buddies'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: otherUsers.length,
                  itemBuilder: (context, index) {
                    return _buildRow(index);
                  },
                ),
              ),
              activeChats.isEmpty
                  ? primaryButton(
                      action: () => _getNewChatFriend(),
                      'Find new buddy',
                    )
                  : Spacer(),
              Text(
                  "You've reached the maximum number of free chats. Upgrade to premium for unlimited chats.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 18.0,
                  )),
              Spacer()
            ],
          )),
    );
  }
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

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatRoom;
  final Map<String, dynamic> otherUser;
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

class _ChatScreenState extends State<ChatScreen> {
  // Storage
  final storageRef = FirebaseStorage.instance.ref().child("audioMessages/");

  // Firebase
  final users = FirebaseFirestore.instance.collection('users');
  final chats = FirebaseFirestore.instance.collection('rooms');

  // UI
  var _messages = [];
  var _messageWidgets = [];

  bool _isRecording = false;
  final record = Record();
  int _recordDuration = 0;
  Timer? _timer;

  final TextEditingController _controller = TextEditingController();
  bool canSend = false;
  bool isSending = false;

  @override
  void initState() {
    _controller.addListener(() {
      setState(() {
        canSend = _controller.text.isNotEmpty;
      });
    });

    _getMessages();

    setState(() {});
    super.initState();
  }

  void _getMessages() async {
    String chatRoomId = widget.chatRoom['id'];
    FirebaseFirestore.instance
        .collection("rooms")
        .doc(chatRoomId)
        .collection("messages")
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        var data = change.doc.data();
        print('got data');
        var newMessage = Message.fromMap(data!);
        switch (change.type) {
          case DocumentChangeType.added:
            setState(() {
              _messages.add(newMessage);
              _messages.sort((b, a) =>
                  a.timestamp.toDate().compareTo(b.timestamp.toDate()));
            });
            break;
          case DocumentChangeType.removed:
            _messages.removeWhere((element) =>
                element.timestamp == newMessage.timestamp &&
                element.senderId == newMessage.senderId);
            _messages.sort(
                (b, a) => a.timestamp.toDate().compareTo(b.timestamp.toDate()));
            break;
          case DocumentChangeType.modified:
            print('Modified change received...');
            _messages.removeWhere((element) =>
                element.timestamp == newMessage.timestamp &&
                element.senderId == newMessage.senderId);
            _messages.add(newMessage);
            _messages.sort(
                (b, a) => a.timestamp.toDate().compareTo(b.timestamp.toDate()));
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: primaryColor,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.otherUser['name'],
                  style: const TextStyle(fontSize: 18.0)),
              const SizedBox(height: 3.0),
              Text(
                  'First contact: ${timeAgo(widget.chatRoom['timeOpened'].toDate())}',
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.shade400)),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40.0),
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _messagesColumn()),
                const SizedBox(height: 24.0),
                isSending
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator())
                    : _sendField()
              ],
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
          child: Scrollbar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  // return Text('Hello');
                  return _buildMessage(_messages[index]);
                  // return _buildMessage(_messages[index]);
                },
              ),
            ),
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
    return Text('${_recordDuration}s');
  }

  Widget _sendField() {
    return Row(
      children: [
        IconButton(
            icon: _isRecording
                ? const Icon(Icons.stop_circle)
                : const Icon(Icons.mic),
            onPressed: () {
              if (!_isRecording) {
                _record();
              } else {
                _stopRecording();
              }
              setState(() {
                _isRecording = !_isRecording;
              });
            }),
        Expanded(
            child: _isRecording ? audioRecordingField() : _textSendField()),
        _isRecording
            ? Container()
            : IconButton(
                disabledColor: Colors.indigo.shade200,
                color: primaryColor,
                onPressed: canSend
                    ? () {
                        _handleSendPressed();
                        _controller.clear();
                      }
                    : null,
                icon: const Icon(Icons.send),
              ),
      ],
    );
  }

  _handleSendPressed() {
    setState(() {
      isSending = true;
    });
    Message newMessage = Message(
        isAudio: false,
        timestamp: Timestamp.now(),
        contents: _controller.text,
        senderId: persistence.firebaseUserId(widget.prefs) ?? '');
    String chatRoomId = widget.chatRoom['id'];
    FirebaseFirestore.instance
        .collection("rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toJson());
    FirebaseFirestore.instance
        .collection("rooms")
        .doc(chatRoomId)
        .update({"lastMessage": _controller.text});
    setState(() {
      isSending = false;
    });

    // _addMessageWidget(newMessage);
  }

  Widget _buildMessage(Message message) {
    bool wasSentByMe =
        message.senderId == persistence.firebaseUserId(widget.prefs);
    bool isAudio = message.isAudio;

    return Column(
      children: [
        Align(
          alignment: wasSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
              constraints:
                  const BoxConstraints(minHeight: 32.0, maxWidth: 275.0),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: wasSentByMe ? primaryColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          style: wasSentByMe
                              ? const TextStyle(color: Colors.white)
                              : const TextStyle(color: Colors.black),
                          message.contents!,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ))),
        ),
        const SizedBox(height: 5.0),
        Align(
          alignment: wasSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Text('${formattedDate(message.timestamp.toDate())}',
              style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600)),
        ),
        isAudio ? const SizedBox(height: 4.5) : Container(),
        Align(
          alignment: wasSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: isAudio
              ? Text('Transcribed audio',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w300))
              : Container(),
        ),
        const SizedBox(height: 18.0),
      ],
    );
  }

  void _record() async {
    if (await Permission.microphone.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.

      setState(() {
        _isRecording = true;
      });

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String filePath = '$tempPath/audio-recording.m4a';
      print('Recording to $filePath');

      // Start recording
      await record.start(
        path: filePath,
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
      );

      setState(() {
        _recordDuration = 0;
        _startTimer();
      });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permission denied'),
              content: const Text('Please grant microphone permission'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          });
    }
  }

  void _stopRecording() async {
    _timer?.cancel();
    _recordDuration = 0;

    await record.stop().then((path) {
      print('Recorded to $path');
      setState(() {
        _isRecording = false;
      });
    });

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String filePath = '$tempPath/audio-recording.m4a';
    File file = File(filePath);

    Uuid uuid = const Uuid();
    String fileName = uuid.v4();
    try {
      var uploadTask =
          storageRef.child("audio-recording-$fileName").putFile(file);
      var audioUrl = await (await uploadTask).ref.getDownloadURL();
      _sendAudioMessage(audioUrl);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  void _sendAudioMessage(audioURL) async {
    setState(() {
      isSending = true;
    });
    String chatRoomId = widget.chatRoom['id'];

    Message newMessage = Message(
        isAudio: true,
        timestamp: Timestamp.now(),
        contents: 'Audio message... waiting to transcribe',
        senderId: persistence.firebaseUserId(widget.prefs) ?? '');
    var doc = await FirebaseFirestore.instance
        .collection("rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toJson());
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://localhost:4996/transcribe-audio'));
    request.fields.addAll(
        {'audio_url': audioURL, 'message_id': doc.id, 'room_id': chatRoomId});

    http.StreamedResponse response = await request.send();
    print(response);
    setState(() {
      isSending = false;
    });
    await FirebaseFirestore.instance
        .collection("rooms")
        .doc(chatRoomId)
        .update({"lastMessage": 'Audio message'});
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}

String timeAgo(DateTime date, {bool numericDates = true}) {
  final date2 = DateTime.now();
  final difference = date2.difference(date);

  if ((difference.inDays / 7).floor() >= 1) {
    return (numericDates) ? '1 week ago' : 'Last week';
  } else if (difference.inDays >= 2) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays >= 1) {
    return (numericDates) ? '1 day ago' : 'Yesterday';
  } else if (difference.inHours >= 2) {
    return '${difference.inHours} hours ago';
  } else if (difference.inHours >= 1) {
    return (numericDates) ? '1 hour ago' : 'An hour ago';
  } else if (difference.inMinutes >= 2) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inMinutes >= 1) {
    return (numericDates) ? '1 minute ago' : 'A minute ago';
  } else if (difference.inSeconds >= 3) {
    return '${difference.inSeconds} seconds ago';
  } else {
    return 'Just now';
  }
}

String formattedDate(DateTime tm) {
  DateTime today = new DateTime.now();
  Duration oneDay = new Duration(days: 1);
  Duration twoDay = new Duration(days: 2);
  Duration oneWeek = new Duration(days: 7);
  String month;
  switch (tm.month) {
    case 1:
      month = "January";
      break;
    case 2:
      month = "February";
      break;
    case 3:
      month = "March";
      break;
    case 4:
      month = "April";
      break;
    case 5:
      month = "May";
      break;
    case 6:
      month = "June";
      break;
    case 7:
      month = "July";
      break;
    case 8:
      month = "August";
      break;
    case 9:
      month = "September";
      break;
    case 10:
      month = "October";
      break;
    case 11:
      month = "November";
      break;
    case 12:
      month = "December";
      break;
  }

  Duration difference = today.difference(tm);

  if (difference.compareTo(oneDay) < 1) {
    return "Today";
  } else if (difference.compareTo(twoDay) < 1) {
    return "Yesterday";
  } else if (difference.compareTo(oneWeek) < 1) {
    switch (tm.weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
    }
  } else if (tm.year == today.year) {
    return '${tm.day} ${tm.month}';
  } else {
    return '${tm.day} ${tm.month} ${tm.year}';
  }

  return tm.toString();
}
