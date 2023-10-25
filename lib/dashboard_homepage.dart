import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:notify_inapp/notify_inapp.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qtcare_therapist/core/utils/app_url.dart';
import 'package:qtcare_therapist/patients_listview.dart';
import 'package:qtcare_therapist/therapist_calendar.dart';
import 'package:qtcare_therapist/video_call_new_agora.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'qtcare_chatroom_messaging_widget.dart';
import 'callandroid.dart';
import 'constant.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.from(
          colorScheme: const ColorScheme.light(),
        ).copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
            },
          ),
        ),
        home: const DashboardHomePage());
  }
}

class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({super.key});

  @override
  _DashboardHomePageState createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  String _displayspecialty = "pseudo goes here";
  String _displaylastname = "avatar url";
  String _displayemail = "email goes here";
  String _displayname = "pseudo goes here";
  final _database = FirebaseDatabase.instance.ref();

  @override
  void dispose() {
    dispose();
    super.dispose();
  }

  void _activateListenername() {
    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();
    _database.child('therapists/$uid/name').onValue.listen((event) {
      final String pseudo = event.snapshot.value.toString();
      setState(() {
        _displayname = pseudo;
        print(_displayname);
      });
    });
  }

  void _activateListenerLastname() {
    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();
    _database.child('therapists/$uid/lastname').onValue.listen((event) {
      final String pseudo = event.snapshot.value.toString();
      setState(() {
        _displaylastname = pseudo;
      });
    });
  }

  void _activateListenerEmail() {
    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();
    _database.child('therapists/$uid/mail').onValue.listen((event) {
      final String pseudo = event.snapshot.value.toString();
      setState(() {
        _displayemail = pseudo;
      });
    });
  }

  void _activateListenerspecialty() {
    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();
    _database.child('therapists/$uid/specialty').onValue.listen((event) {
      final String pseudo = event.snapshot.value.toString();
      setState(() {
        _displayspecialty = pseudo;
      });
    });
  }

  @override
  void initState() {

    super.initState();
    checkFirstTime();
    _activateListenername();
    _activateListenerLastname();
    _activateListenerspecialty();
    _activateListenerEmail();
    signupToken();

    // initialize agora sdk
  }
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background messages here
  }

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    return MaterialApp(home: Builder(builder: (context) {
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
          )
          ,
        );

      });

      return Scaffold(
          appBar: AppBar(
            backgroundColor: appBarColor,
            title: const Text('Qtcare therapist dashboard'),
            centerTitle: false,
          ),
          drawer: Drawer(
            backgroundColor: const Color.fromRGBO(16, 212, 177, 1),
            elevation: 0,
            child: Column(
              children: [
                DrawerHeader(
                    child: SizedBox(
                        width: 200,
                        height: 60,
                        child: Image.asset('assets/vectors/qtcarewhite.png'))),
                Padding(
                  padding: tilePadding,
                  child: ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(
                        'D A S H B O A R D',
                        style: drawerTextColor,
                      ),
                      onTap: () => print("dashboard")),
                ),
                Padding(
                  padding: tilePadding,
                  child: ListTile(
                      leading: const Icon(Icons.settings),
                      title: Text(
                        'P A T I E N T S',
                        style: drawerTextColor,
                      ),
                      onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                                return PatientView();
                              },
                            ),
                          )),
                ),
                Padding(
                  padding: tilePadding,
                  child: ListTile(
                      leading: const Icon(Icons.info),
                      title: Text(
                        'C A L E N D E R',
                        style: drawerTextColor,
                      ),
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalendarWidget(),
                            ),
                          )),
                ),
                Padding(
                  padding: tilePadding,
                  child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(
                        'L O G O U T',
                        style: drawerTextColor,
                      ),
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('openedBefore', true);

                        await FirebaseAuth.instance.signOut();
                      }),
                ),
              ],
            ),
          ),
          body: LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                const Center(
                    child: SizedBox(
                  height: 40,
                )),
                SizedBox(
                    height: constraints.maxHeight * 0.4,
                    width: constraints.maxWidth * 0.8,
                    child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                            bottomLeft: Radius.circular(35),
                            bottomRight: Radius.circular(35),
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(
                                    150, 156, 156, 0.8999999761581421),
                                offset: Offset(1, 1),
                                blurRadius: 3)
                          ],
                          gradient: LinearGradient(
                              begin: Alignment(0.5, 0.5),
                              end: Alignment(-0.5, 0.5),
                              colors: [
                                Color.fromRGBO(246, 255, 255, 1),
                                Color.fromRGBO(222, 231, 232, 1)
                              ]),
                        ),
                        child: Column(
                          children: [
                            const Center(
                                child: SizedBox(
                            )),
                            SizedBox(
                                height: 60,
                                width: 60,
                                child: new Image.asset(
                                  "assets/vectors/therapist.png",
                                  height: 60,
                                  width: 60,
                                )),
                            const Center(
                                child: SizedBox(
                              height: 10,
                            )),
                            Text(
                              "name:" + _displayname,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            ),
                            const Center(
                                child: SizedBox(
                              height: 10,
                            )),
                            Text(
                              "lastname:" + _displaylastname,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            ),
                            const Center(
                                child: SizedBox(
                              height: 10,
                            )),
                            Text(
                              "email:" + _displayemail,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            ),
                            const Center(
                                child: SizedBox(
                              height: 10,
                            )),
                            Text(
                              "specialty:$_displayspecialty",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            ),
                            const Center(
                                child: SizedBox(
                              height: 10,
                            )),
                            SizedBox(
                                height: 50,
                                width: 300,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape:
                                          const CircleBorder(), //<-- SEE HERE
                                    ),
                                    onPressed: () {},
                                    child: const Text("modify")))
                          ],
                        ))),
                const Center(
                    child: SizedBox(
                  height: 40,
                )),

              ],
            );
          }));
      // Your initialization for material app.
    }));
  }

  signupRequest(String agorausername) async {
    final uri = Uri.parse('http://a61.chat.agora.io/61749142/984846/users');
    final headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $_signuptoken"
    };
    Map<String, dynamic> body = {
      'username': agorausername,
      'nickname': agorausername,
      'password': agorausername
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    int? statusCode = response.statusCode;
    String responseBody = response.body;
    print(statusCode);
    print(responseBody);
  }

  Future<void> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool openedBefore = prefs.getBool('openedBefore') ?? false;

    if (!openedBefore) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("therapists");
      User? user = FirebaseAuth.instance.currentUser;
      String uid = user!.uid;
      final fcmToken = await FirebaseMessaging.instance.getToken();

      await ref.child(uid).update({
        "fcmtoken":fcmToken.toString(),
      });
      print('First time opening the widget');
      // ...

      // Update the flag to indicate the widget has been opened before
      await prefs.setBool('openedBefore', true);
    }
  }


  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  String _signuptoken = "";

  signupToken() async {
    final uri = Uri.parse(AppUrls.agoraGetSignUpToken);

    http.Response response = await http.get(
      uri,
    );

    int? statusCode = response.statusCode;
    String responseBody = response.body;
    if (kDebugMode) {
      print("agora user signup attempt: " + statusCode.toString());
    }
    if (kDebugMode) {
      print(responseBody);
    }
    setState(() {
      _signuptoken = responseBody;
    });
  }

  Future<void> onJoinqtcarevideocall() async {
    // update input validation
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CallWidget(
          channelName: "test",
          role: ClientRole.Broadcaster,
        ),
      ),
    );
  }
}
