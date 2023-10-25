import 'dart:async';
import 'dart:convert';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:notify_inapp/notify_inapp.dart';
import 'package:qtcare_therapist/core/utils/app_url.dart';
import 'package:qtcare_therapist/services/push_notification_service.dart';
import 'package:uuid/uuid.dart';

import 'Models/messageModel.dart';

class AgoraChatConfig {
  static const String appKey = "61749142#984846";
}

class QtCareChatRoomMessaging extends StatefulWidget {
  const QtCareChatRoomMessaging(
      {Key? key, required this.receiver, required this.sender, required this.patientid})
      : super(key: key);
  final String sender;
  final String receiver;
  final String patientid;

  @override
  State<QtCareChatRoomMessaging> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<QtCareChatRoomMessaging> {
  final ScrollController _scrollController = ScrollController();
  String patientsName = "avatar url";

  String? _messageContent;
  List<String> _logText = [];
  List<messageModel> messageList = [];
  bool _isVisible = false;
  String uniqueHandlerId = const Uuid().v4();

  String _fcmPatient= "";
  Future<String> _getPatientFcm() async {
    final _database = FirebaseDatabase.instance.ref();

    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();
    String fcmPatient = '';
    Completer<String> completer = Completer<String>();
    _database.child('users/${widget.patientid}/fcmtoken').onValue.listen((event) {
      fcmPatient = event.snapshot.value.toString();
      setState(() {
        _fcmPatient = fcmPatient;
      });
      completer.complete(fcmPatient);
    });
    await completer.future;
    return fcmPatient;
  }

  @override
  void initState() {
    super.initState();
    _getPatientFcm();
    _initSDK();
    _signIn();
    _addChatListener();
    _logText = _logText.toSet().toList();
    getMessageHistory(messageList);
  }

  @override
  void dispose() {
    ChatClient.getInstance.chatManager.removeMessageEvent(uniqueHandlerId);
    ChatClient.getInstance.chatManager.removeEventHandler(uniqueHandlerId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      print('Received message: ${message.notification?.body}');
      Notify notify = Notify();
      notify.show(
        context,
        Container(
          width: 300,
          height: 100,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (message.notification?.title).toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                (message.notification?.body).toString(),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(16, 212, 177, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () async {},
          ),
        ],
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                _signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: Text(widget.receiver),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 10),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (_, index) {
                  return Column(
                    children: [
                      /*SizedBox(width: _logText[index].contains("receive text message")
                            ? 0
                            :160,),

                            _logText[index].split('receive text message:')[1]
                            */
                      InkWell(
                        child: BubbleSpecialThree(
                          text: messageList[index].content,
                          color: messageList[index].sender != widget.sender
                              ? const Color.fromRGBO(16, 212, 177, 1)
                              : Colors.teal,
                          isSender: messageList[index].sender != widget.sender
                              ? false
                              : true,
                          tail: true,
                          textStyle: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        onTap: () {
                          _isVisible = !_isVisible;
                          setState(() {
                            // Here you can write your code for open new view
                          });
                        },
                      ),
                      Column(
                        children: [
                          Text(
                            messageList[index].messagetime,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontFamily: 'Okta Neue',
                                fontSize: 10,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.normal,
                                height: 1.1111111111111112),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ],
                  );
                },
                itemCount: messageList.length,
              ),
            ),
            MessageBar(
              sendButtonColor: const Color.fromRGBO(16, 212, 177, 1),
              onSend: (msg) async {
                _messageContent = msg;

                if (kDebugMode) {
                  print(
                      "attempting to send message $msg to ${widget.receiver} from ${widget.sender} ");
                }
                if (kIsWeb) {
                  // This code will only execute on web devices
                  print('Running on web!');
                } else {
                  sendPushNotification(
                      _fcmPatient, 'New Message', "${widget.sender}: $msg");
                }

                _sendMessage();
                _logText = _logText.toSet().toList();
                messageList = messageList.toSet().toList();
                final ids = messageList.map((e) => e.messagetime).toSet();
                messageList.retainWhere((x) => ids.remove(x.messagetime));

                print(_logText);
                Future.delayed(const Duration(milliseconds: 500), () {
                  final position = _scrollController.position.maxScrollExtent;
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
                  setState(() {
                    // Here you can write your code for open new view
                  });
                });
              },
              actions: [],
            ),
          ],
        ),
      ),
    );
  }

  void _initSDK() async {
    ChatOptions options = ChatOptions(
      appKey: AgoraChatConfig.appKey,
      autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
    await ChatClient.getInstance.startCallback();
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    for (var msg in messages) {
      switch (msg.body.type) {
        case MessageType.TXT:
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            _addLogToConsole(
              "receive text message: ${body.content}, from: ${msg.from}",
            );
            setState(() {
              print("was recieved");
              messageList.add(messageModel(
                  messagetime: _timeString,
                  sender: msg.from.toString(),
                  content: body.content));
              messageList = messageList.toSet().toList();
              final ids = messageList.map((e) => e.messagetime).toSet();
              messageList.retainWhere((x) => ids.remove(x.messagetime));
            });
          }
          break;
        case MessageType.IMAGE:
          {
            ChatImageMessageBody body = msg.body as ChatImageMessageBody;

            _addLogToConsole(
              "receive image message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.VIDEO:
          {
            _addLogToConsole(
              "receive video message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.LOCATION:
          {
            _addLogToConsole(
              "receive location message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.VOICE:
          {
            _addLogToConsole(
              "receive voice message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.FILE:
          {
            _addLogToConsole(
              "receive image message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.CUSTOM:
          {
            _addLogToConsole(
              "receive custom message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.CMD:
          {
            // Receiving command messages does not trigger the `onMessagesReceived` event, but triggers the `onCmdMessagesReceived` event instead.
          }
          break;
      }
    }

    setState(() {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      _logText = _logText.toSet().toList();
      messageList = messageList.toSet().toList();
      final ids = messageList.map((e) => e.messagetime).toSet();
      messageList.retainWhere((x) => ids.remove(x.messagetime));
    });
  }

  void _signIn() async {
    try {
      await ChatClient.getInstance.login(
        widget.sender,
        widget.sender,
      );
      _addLogToConsole("login succeed, userId: ${widget.sender}");
    } on ChatError catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
      _addLogToConsole("sign out succeed");
    } on ChatError catch (e) {
      _addLogToConsole(
          "sign out failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _sendMessage() async {
    if (widget.receiver == null || _messageContent == null) {
      _addLogToConsole("single chat id or message content is null");
      return;
    }
    var msg = ChatMessage.createTxtSendMessage(
      targetId: widget.receiver,
      content: _messageContent!,
    );
    _addLogToConsole("send message: $_messageContent");
    messageList.add(messageModel(
        messagetime: _timeString,
        sender: widget.sender,
        content: _messageContent.toString()));
    setState(() {
      messageList = messageList.toSet().toList();
      final ids = messageList.map((e) => e.messagetime).toSet();
      messageList.retainWhere((x) => ids.remove(x.messagetime));
    });
    ChatClient.getInstance.chatManager.sendMessage(msg);

    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();
    DateTime now = DateTime.now();

    DatabaseReference refpatientid =
        FirebaseDatabase.instance.ref("appointment_room");

    Query query = refpatientid.orderByChild("idtherapist").equalTo(uid);
    DataSnapshot eventtherpistid = await query.get();
    Map<dynamic, dynamic> roomidbypatioent = {};
    roomidbypatioent = eventtherpistid.value as Map;
    if (kDebugMode) {
      print("this is the room id:" + roomidbypatioent.keys.first);
    }

    DatabaseReference ref = FirebaseDatabase.instance
        .ref("appointment_room")
        .child(roomidbypatioent.keys.first)
        .child("messagelog")
        .child(_timeString);
    ref.set({
      "messagecontent": _messageContent,
      "sender": widget.sender,
      "time": _timeString,
    });
  }

  void _addChatListener() {
    ChatClient.getInstance.chatManager.addMessageEvent(
        uniqueHandlerId,
        ChatMessageEvent(
          onSuccess: (msgId, msg) {
            _addLogToConsole("send message succeed");
          },
          onProgress: (msgId, progress) {
            _addLogToConsole("send message succeed");
          },
          onError: (msgId, msg, error) {
            _addLogToConsole(
              "send message failed, code: ${error.code}, desc: ${error.description}",
            );
          },
        ));

    ChatClient.getInstance.chatManager.addEventHandler(
      uniqueHandlerId,
      ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );
  }

  void _addLogToConsole(String log) {
    _logText.add("$_timeString: $log");
    setState(() {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }

  Future<void> getMessageHistory(List<messageModel> messageList) async {
    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();
    DateTime now = DateTime.now();
    DatabaseReference refPatientId =
        FirebaseDatabase.instance.ref("appointment_room");

    Query query = refPatientId.orderByChild("idtherapist").equalTo(uid);
    DataSnapshot eventTherapistId = await query.get();
    Map<dynamic, dynamic> roomIdByPatioent = {};
    roomIdByPatioent = eventTherapistId.value as Map;
    print(roomIdByPatioent.keys.first);

    DatabaseReference refMessageLog = FirebaseDatabase.instance
        .ref("appointment_room")
        .child(roomIdByPatioent.keys.first)
        .child("messagelog");

    DataSnapshot eventGetMessages = await refMessageLog.get();
    Map<dynamic, dynamic> historyMessageList = {};
    historyMessageList = eventGetMessages.value as Map;
    if (kDebugMode) {
      print(historyMessageList.keys);
    }
    historyMessageList.forEach((key, value) {
      setState(() {
        messageList.add(messageModel(
            messagetime: value["time"],
            sender: value["sender"],
            content: value[
                "messagecontent"])); // Here you can write your code for open new view
      });
    });
  }
}
