import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notify_inapp/notify_inapp.dart';
import 'package:qtcare_therapist/states/form_status.dart';
import 'package:qtcare_therapist/states/login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/auth_repo.dart';
import 'bloc/login_bloc.dart';
import 'dashboard_homepage.dart';
import 'event/login_event.dart';

class LoginWidget extends StatelessWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; //getting the size property
    final orientation = MediaQuery.of(context).orientation;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _formKey = GlobalKey<FormState>();
  late bool _userok = false;
  late bool _passok = false;
  bool isFirstTime = true;

  final textController = TextEditingController();


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  Animatable<Color?> background = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.tealAccent[400],
        end: Colors.green,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.green,
        end: Colors.blue,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.blue,
        end: Colors.tealAccent[400],
      ),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return MaterialApp(
              home:

              RepositoryProvider(
                  create: (context) => AuthRepository(),
                  child: Scaffold(
                      body: BlocProvider(
                          create: (context) => LoginBloc(
                                authRepo: context.read<AuthRepository>(),
                              ),
                          child: LayoutBuilder(builder: (context, constraints) {
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


                            return Container(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                color: background.evaluate(
                                    AlwaysStoppedAnimation(_controller.value)),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          SizedBox(
                                              width: constraints.maxWidth * 0.8,
                                              height:
                                                  constraints.maxHeight * 0.2,
                                              child: Image.asset(
                                                  "assets/vectors/qtcarewhite.png")),
                                          Padding(
                                            padding: const EdgeInsets.all(30.0),
                                            child: SizedBox(
                                              width: constraints.maxWidth * 0.6,
                                              child: Text(
                                                'Welcome to QTcare',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: const Color.fromRGBO(
                                                        255, 255, 255, 1),
                                                    fontFamily: 'Montserrat',
                                                    fontSize:
                                                        constraints.maxWidth *
                                                            0.06,
                                                    letterSpacing:
                                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    height: 1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: _loginform(constraints),
                                            )
                                          ]),
                                    ]));
                          })))));
        });
  }

  Widget _passwordField(BoxConstraints constraints) {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextFormField(
          validator: (value) {
            if (_passok == false) {
              return 'password too short';
            }
            return null;
          },
          onChanged: (value) {
            context.read<LoginBloc>().add(
                  LoginPasswordChanged(password: value),
                );
            _passok = state.isValidPassword;
          },
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: new Icon(Icons.key),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: const BorderSide(
                width: 6,
                style: BorderStyle.none,
              ),
            ),
            hintText: 'Password',
            hintStyle: const TextStyle(
                color: Color.fromRGBO(60, 60, 67, 1),
                fontFamily: 'Montserrat',
                fontSize: 11,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
                height: 1),
          ));
    });
  }

  Widget _usernameField() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextFormField(
        validator: (value) {
          if (_userok == false) {
            return 'username too short';
          }
          return null;
        },
        onChanged: (value) {
          context.read<LoginBloc>().add(
                LoginUsernameChanged(username: value),
              );
          _userok = state.isValidUsername;
          print(value);
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: new Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(
              width: 6,
              style: BorderStyle.none,
            ),
          ),
          hintText: 'therapist access key ',
          hintStyle: const TextStyle(
              color: Color.fromRGBO(60, 60, 67, 1),
              fontFamily: 'Montserrat',
              fontSize: 11,
              letterSpacing: 0,
              fontWeight: FontWeight.normal,
              height: 1),
        ),
      );
    });
  }

  Widget _loginButton(BoxConstraints constraints) {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return state.formStatus is FormSubmitting
          ? const CircularProgressIndicator()
          : SizedBox(
              width: constraints.maxWidth * 0.3, // <-- match_parent
              height: constraints.maxHeight * 0.05,
              child: ElevatedButton(
                  onPressed: () {
                    context.read<LoginBloc>().add(LoginSubmitted());
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(37),
                        topRight: Radius.circular(37),
                        bottomLeft: Radius.circular(37),
                        bottomRight: Radius.circular(37),
                      ),
                    )),
                  ),
                  child: const Text('Login')));
    });
  }

  Widget _loginform(BoxConstraints constraints) {
    return BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.emailnotfound == true) {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return SizedBox(
                      width: constraints.maxWidth * 0.06,
                      child: const AlertDialog(
                        title: Text('incorrect password or email',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Okta Neue',
                                fontSize: 18,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.bold,
                                height: 1.1111111111111112)),
                        backgroundColor: Colors.red,
                        content: Text('retype your credentials'),
                      ));
                });
          }
          final formStatus = state.formStatus;
          if (formStatus is SubmissionFailed) {
            _showSnackBar(context, formStatus.exception.toString());
          }
        },
        child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.01,
                  vertical: constraints.maxWidth * 0.01),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                          'Please, Log In.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: const Color.fromRGBO(255, 255, 255, 1),
                              fontFamily: 'Montserrat',
                              fontSize: constraints.maxWidth * 0.03,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                        top: constraints.maxHeight * 0.02,
                      ),
                      child: SizedBox(
                        height: constraints.maxHeight * 0.07,
                        width: constraints.maxWidth * 0.8,
                        child: _usernameField(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: constraints.maxHeight * 0.02,
                      ),
                      child: SizedBox(
                        height: constraints.maxHeight * 0.07,
                        width: constraints.maxWidth * 0.8,

                        child: _passwordField(constraints),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                          top: constraints.maxHeight * 0.01,
                        ),
                        child: _loginButton(constraints)),
                  ]),
            )));
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBe17Nn64kvHnHsKNeFwIVhGfDXzCUYF0E",
      // Your apiKey
      appId: "1:389996433093:android:bfc054daaf1b575b7d2aac",
      // Your appId
      messagingSenderId: "389996433093",
      // Your messagingSenderId
      projectId: "qtcare-healthapp",
      databaseURL:
          "https://qtcare-healthapp-default-rtdb.firebaseio.com/", // Your projectId
    ),
  );
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kIsWeb) {
    // This code will only execute on web devices
    print('Running on web!');
  } else {

    Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
      // Handle background messages here
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      print("this is the fcm token: $fcmToken");
    }    print('Not running on web!');
  }



  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      if (kDebugMode) {
        print('User is currently signed out!');
      }
      runApp(const LoginPage());
    } else {
      print('User is signed in!');
      runApp(const DashboardPage());
    }
  });

  //runApp(RootScreen());
}
