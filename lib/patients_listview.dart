import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qtcare_therapist/patient_overview.dart';
import 'package:qtcare_therapist/therapist_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';
import 'dashboard_homepage.dart';

class PatientView extends StatefulWidget {
  @override
  _PatientViewState createState() => _PatientViewState();
}

class _PatientViewState extends State<PatientView> {
  User? user;
  List patients = [];
  List patientsAvatar = [];
  List patientsName = [];
  List patientsEmail = [];
  List patientsId = [];
  bool _loading = true;
  Map<dynamic, dynamic> items = {};

  @override
  initState() {
    _getpatientsinfo();
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _getpatientavatar(patients) async {
    for (var patient in patients) {
      DatabaseReference refavatar =
          FirebaseDatabase.instance.ref("users/$patient/avatarurl");
      DatabaseEvent event = await refavatar.once();
      patientsAvatar.add(event.snapshot.value.toString());

      DatabaseReference refname =
          FirebaseDatabase.instance.ref("users/$patient/pseudoname");
      DatabaseEvent event1 = await refname.once();
      patientsName.add(event1.snapshot.value.toString());

      DatabaseReference refemail =
          FirebaseDatabase.instance.ref("users/$patient/email");
      DatabaseEvent event2 = await refemail.once();
      patientsEmail.add(event2.snapshot.value.toString());
    }
    print(patientsAvatar);
    setState(() {});
  }

  Future<List<dynamic>> _getpatientsinfo() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("appointment_room");

    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();

    Query query = ref.orderByChild("idtherapist").equalTo(uid);
    DataSnapshot event = await query.get();
    print(event.value);
    items = event.value as Map;
    patients = items.keys.toList();
    print(patients[0]);
    _getpatientavatar(patients);
    return patients;
  }

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();
    DatabaseReference _patientsref = FirebaseDatabase.instance
        .ref()
        .child("therapists")
        .child(uid)
        .child("patients");
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: appBarColor,
              title: Text('check your patients'),
              centerTitle: false,
            ),
            drawer: Drawer(
              backgroundColor: Color.fromRGBO(16, 212, 177, 1),
              elevation: 0,
              child: Column(
                children: [
                  DrawerHeader(
                      child: SizedBox(
                          width: 200,
                          height: 60,
                          child:
                              Image.asset('assets/vectors/qtcarewhite.png'))),
                  Padding(
                    padding: tilePadding,
                    child: ListTile(
                        leading: Icon(Icons.home),
                        title: Text(
                          'D A S H B O A R D',
                          style: drawerTextColor,
                        ),
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardPage(),
                              ),
                            )),
                  ),
                  Padding(
                    padding: tilePadding,
                    child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text(
                          'P A T I E N T S',
                          style: drawerTextColor,
                        ),
                        onTap: () => print("patients")),
                  ),
                  Padding(
                    padding: tilePadding,
                    child: ListTile(
                        leading: Icon(Icons.info),
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
                        leading: Icon(Icons.logout),
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
            body: Center(
                    child: GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 200,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20),
                            itemCount: patients.length,
                            itemBuilder: (BuildContext ctx, index) {
                              return InkWell(
                                child: Container(
                                  height: 120,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(200),
                                      topRight: Radius.circular(100),
                                      bottomLeft: Radius.circular(400),
                                      bottomRight: Radius.circular(200),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color.fromRGBO(
                                              189, 189, 189, 0.8999999761581421),
                                          offset: Offset(1, 1),
                                          blurRadius: 3)
                                    ],
                                    gradient: LinearGradient(
                                        begin: Alignment(0.5, 0.5),
                                        end: Alignment(-0.5, 0.5),
                                        colors: [
                                          Color.fromRGBO(22, 151, 153, 1),
                                          Color.fromRGBO(139, 197, 173, 1)
                                        ]),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 90,
                                          width: 80,
                                          child: Image.asset(
                                            patientsAvatar[index],
                                            height: 80,
                                            width: 80,
                                          )),
                                      Text(patientsName[index],
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(30, 27, 27, 1.0),
                                              fontSize: 15,
                                              letterSpacing:
                                                  0 /*percentages not used in flutter. defaulting to zero*/,
                                              fontWeight: FontWeight.normal,
                                              height: 1)),
                                      Text(patientsEmail[index],
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1.0),
                                              fontSize: 15,
                                              letterSpacing:
                                                  0 /*percentages not used in flutter. defaulting to zero*/,
                                              fontWeight: FontWeight.normal,
                                              height: 1))
                                    ],
                                  ),

                                  //Text(patients[index].toString()),
                                ),
                                onTap: () {
                                  print(patientsName[index]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PatientInfo(
                                        patientId: patients[index],
                                        patientName: patientsName[index],
                                      ),
                                    ),
                                  );
                                },
                              );
                            })


                    //topbar
                  )));
  }
}
