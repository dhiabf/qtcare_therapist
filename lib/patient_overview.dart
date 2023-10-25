import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notify_inapp/notify_inapp.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qtcare_therapist/callandroid.dart';
import 'package:qtcare_therapist/core/utils/app_url.dart';
import 'package:qtcare_therapist/patients_listview.dart';
import 'package:qtcare_therapist/qtcare_chatroom_messaging_widget.dart';
import 'package:qtcare_therapist/services/push_notification_service.dart';
import 'package:qtcare_therapist/therapist_calendar.dart';
import 'package:http/http.dart' as http;


import 'constant.dart';

const List<String> list = <String>['male', 'female', 'other'];
const List<String> listMartial = <String>[
  'single',
  'married',
  'divorced',
  'other'
];
const List<String> listParentState = <String>[
  'married',
  'seperated',
  'divorced',
  'dead',
  'dead father',
  'dead mother'
];

enum ParentState { married, seperated, divorced, deceased }

class PatientInfo extends StatefulWidget {
  final String? patientId;
  final String? patientName;



  const PatientInfo({Key? key, this.patientId, this.patientName}) : super(key: key);

  @override
  _PatientInfoState createState() => _PatientInfoState();
}

class _PatientInfoState extends State<PatientInfo> {
  String patientAvatar = "";
  String patientsName = "";
  String patientsEmail = "";
  String therapistName = "";

  bool avatarLoaded = false;

  String countryValue = "country";
  String stateValue = "state";
  String cityValue = "city";
  String dropDownValueGender = list.first;
  String dropdownValueMartial = listMartial.first;
  DateTime _selectedDate = DateTime.now();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController sportsController = TextEditingController();
  TextEditingController artsController = TextEditingController();
  TextEditingController otherActivitiesController = TextEditingController();

  String dropdownValueParentState = listParentState.first;
  TextEditingController numberOfSiblingController = TextEditingController();
  TextEditingController ageFatherController = TextEditingController();
  TextEditingController ageMotherController = TextEditingController();
  TextEditingController workFatherController = TextEditingController();
  TextEditingController workMotherController = TextEditingController();

  TextEditingController relationshipIssuesController = TextEditingController();
  TextEditingController healthIssuesController = TextEditingController();
  TextEditingController ecoSocialIssuesController = TextEditingController();
  TextEditingController familyProblemsController = TextEditingController();

  @override
  void dispose() {
    dispose();
    super.dispose();
  }



  Map<dynamic, dynamic> itemsPersonalInfo = {};
  List patientPersonalInfo = [];

  Future<void> _getPatientInfo() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("patientfiles/${widget.patientId}/personal_informations");
    DataSnapshot event = await ref.get();
    itemsPersonalInfo = event.value as Map;
    patientPersonalInfo = itemsPersonalInfo.values.toList();

    DateTime dt = DateTime.parse(patientPersonalInfo[0]);

    setState(() {
      fullnameController.text = patientPersonalInfo[8];
      sportsController.text = patientPersonalInfo[4];
      artsController.text = patientPersonalInfo[5];
      otherActivitiesController.text = patientPersonalInfo[2];
      dropDownValueGender = patientPersonalInfo[6];
      dropdownValueMartial = patientPersonalInfo[1];
      countryValue = patientPersonalInfo[3];
      stateValue = patientPersonalInfo[9];
      cityValue = patientPersonalInfo[7];

      _selectedDate = dt;
    });
  }

  String _fcmPatient= "";
  Future<String> _getPatientFcm() async {
    final _database = FirebaseDatabase.instance.ref();

    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();
    String fcmPatient = '';
    Completer<String> completer = Completer<String>();
    _database.child('users/${widget.patientId}/fcmtoken').onValue.listen((event) {
      fcmPatient = event.snapshot.value.toString();
      setState(() {
        _fcmPatient = fcmPatient;
      });
      completer.complete(fcmPatient);
    });
    await completer.future;
    return fcmPatient;
  }

  Future<void> _getPatientAvatar() async {
    DatabaseReference refAvatar =
        FirebaseDatabase.instance.ref("users/${widget.patientId}/avatarurl");
    DatabaseEvent event = await refAvatar.once();
    patientAvatar = event.snapshot.value.toString();

    DatabaseReference refName =
        FirebaseDatabase.instance.ref("users/${widget.patientId}/pseudoname");
    DatabaseEvent event1 = await refName.once();
    patientsName = event1.snapshot.value.toString();

    DatabaseReference refEmail =
        FirebaseDatabase.instance.ref("users/${widget.patientId}/email");
    DatabaseEvent event2 = await refEmail.once();
    patientsEmail = event2.snapshot.value.toString();
    setState(() {
      avatarLoaded = true;
    });
  }

  void _getTherapistUsername() {
    final database = FirebaseDatabase.instance.ref();
    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();
    database.child('therapists/$uid/name').onValue.listen((event) {
      final String pseudo = event.snapshot.value.toString();
      setState(() {
        therapistName = pseudo;
      });
    });
  }



  @override
  void initState() {
    super.initState();
    _getPatientFcm();
    _getTherapistUsername();
    _getPatientAvatar();
    _getPatientInfo();
    // initialize agora sdk
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Builder(builder: (context) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: appBarColor,
            title: const Text('patient informations'),
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
                      onTap: () {} ),
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
                              builder: (context) => const CalendarWidget(),
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
                        await FirebaseAuth.instance.signOut();
                      }),
                ),
              ],
            ),
          ),
          body: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
                child: Column(
              children: [
                Center(
                    child: SizedBox(
                  height: constraints.maxHeight * 0.02,
                )),
                SizedBox(
                    height: constraints.maxHeight * 0.30,
                    width: constraints.maxWidth * 0.9,
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
                                Color.fromRGBO(144, 213, 126, 1.0),
                                Color.fromRGBO(168, 210, 159, 1.0)
                              ]),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Center(
                                  child: SizedBox(
                                height: constraints.maxHeight * 0.01,
                              )),
                              Visibility(
                                visible: avatarLoaded,
                                child: SizedBox(
                                    height: constraints.maxHeight * 0.12,
                                    width: constraints.maxHeight * 0.12,
                                    child: Image.asset(
                                      patientAvatar,
                                      height: 60,
                                      width: 60,
                                    )),
                              ),
                              Center(
                                  child: SizedBox(
                                height: constraints.maxHeight * 0.01,
                              )),
                              Text(
                                "pseudoname:$patientsName",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: const Color.fromRGBO(0, 0, 0, 1),
                                    fontFamily: 'Inter',
                                    fontSize: constraints.maxHeight * 0.02,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              ),
                              Center(
                                  child: SizedBox(
                                height: constraints.maxHeight * 0.01,
                              )),
                              Center(
                                  child: SizedBox(
                                height: constraints.maxHeight * 0.01,
                              )),
                              Text(
                                "email:$patientsEmail",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: const Color.fromRGBO(0, 0, 0, 1),
                                    fontFamily: 'Inter',
                                    fontSize: constraints.maxHeight * 0.02,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {



                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                QtCareChatRoomMessaging(sender: therapistName, receiver: patientsName, patientid: widget.patientId.toString(),),
                                          ),
                                        );


                                      },
                                      child: const Text("message")),
                                  const SizedBox(width: 10,),

                                  ElevatedButton(
                                      onPressed: () async {



                                         onJoinqtcarevideocall(widget.patientId.toString(),widget.patientName.toString());



                                      },
                                      child: const Text("call")),
                                ],
                              ),
                              Center(
                                  child: SizedBox(
                                height: constraints.maxHeight * 0.01,
                              )),
                              Center(
                                  child: SizedBox(
                                height: constraints.maxHeight * 0.01,
                              )),
                            ],
                          ),
                        ))),
                Center(
                    child: SizedBox(
                  height: constraints.maxHeight * 0.02,
                )),
                SizedBox(
                    height: 620,
                    width: constraints.maxWidth * 0.9,
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
                        child: Center(
                          child: Column(
                            children: [
                              const Center(
                                  child: SizedBox(
                                height: 40,
                              )),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              const Text(
                                "personal information",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 250,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: _selectedDate ==
                                            DateTime
                                                .now() //ternary expression to check if date is null
                                        ? 'birthday!'
                                        : ' ${DateFormat.yMMMd().format(_selectedDate)}',
                                    suffixIcon: IconButton(
                                      onPressed: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: _selectedDate,
                                          // Refer step 1
                                          firstDate: DateTime(1990),
                                          lastDate: DateTime(2004),
                                        );
                                        if (picked != null &&
                                            picked != _selectedDate) {
                                          setState(() {
                                            _selectedDate = picked;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.calendar_month),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 250,
                                child: TextField(
                                  controller: fullnameController,
                                  decoration: const InputDecoration(
                                      hintText: 'full name'),
                                ),
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 70,
                                  ),
                                  DropdownButton<String>(
                                    value: dropDownValueGender,
                                    icon: const Icon(
                                        Icons.arrow_drop_down_circle_outlined),
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.deepPurple),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        dropDownValueGender = value!;
                                      });
                                    },
                                    items: list.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  DropdownButton<String>(
                                    value: dropdownValueMartial,
                                    icon: const Icon(
                                        Icons.arrow_drop_down_circle_outlined),
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.deepPurple),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        dropdownValueMartial = value!;
                                      });
                                    },
                                    items: listMartial
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(countryValue),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(stateValue),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(cityValue),
                                  IconButton(
                                    icon: const Icon(Icons.location_on_rounded),
                                    tooltip: 'select country',
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Material(
                                                color: const Color.fromRGBO(
                                                    0, 0, 0, 0),
                                                child: Center(
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(35),
                                                        topRight:
                                                            Radius.circular(35),
                                                        bottomLeft:
                                                            Radius.circular(35),
                                                        bottomRight:
                                                            Radius.circular(35),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Color.fromRGBO(
                                                                150,
                                                                156,
                                                                156,
                                                                0.8999999761581421),
                                                            offset:
                                                                Offset(1, 1),
                                                            blurRadius: 3)
                                                      ],
                                                      gradient: LinearGradient(
                                                          begin: Alignment(
                                                              0.5, 0.5),
                                                          end: Alignment(
                                                              -0.5, 0.5),
                                                          colors: [
                                                            Color.fromRGBO(246,
                                                                255, 255, 1),
                                                            Color.fromRGBO(222,
                                                                231, 232, 1)
                                                          ]),
                                                    ),
                                                    width: 300,
                                                    height: 200,
                                                    child: SelectState(
                                                      onCountryChanged:
                                                          (value) {
                                                        setState(() {
                                                          countryValue = value;
                                                        });
                                                      },
                                                      onStateChanged: (value) {
                                                        setState(() {
                                                          stateValue = value;
                                                        });
                                                      },
                                                      onCityChanged: (value) {
                                                        setState(() {
                                                          cityValue = value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ));
                                          });

                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              TextField(
                                controller: sportsController,
                                decoration:
                                    const InputDecoration(hintText: 'sports'),
                              ),
                              TextField(
                                controller: artsController,
                                decoration: const InputDecoration(
                                    hintText: 'artistic activities'),
                              ),
                              TextField(
                                controller: otherActivitiesController,
                                decoration: const InputDecoration(
                                    hintText: 'other activities'),
                              ),
                              const Center(
                                  child: SizedBox(
                                height: 25,
                              )),
                              SizedBox(
                                  height: 30,
                                  width: 70,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        String birthday =
                                            _selectedDate.toString();
                                        DatabaseReference ref =
                                            FirebaseDatabase.instance.ref(
                                                "patientfiles/${widget.patientId}/personal_informations");

                                        await ref.set({
                                          "fullname": fullnameController.text,
                                          "sports_activities":
                                              sportsController.text,
                                          "art_activities": artsController.text,
                                          "other_activities":
                                              otherActivitiesController.text,
                                          "maritial_status":
                                              dropdownValueMartial,
                                          "gender": dropDownValueGender,
                                          "country": countryValue,
                                          "state": stateValue,
                                          "city": cityValue,
                                          "birthday": birthday,
                                        });
                                      },
                                      child: const Text("save")))
                            ],
                          ),
                        ))),
                Center(
                    child: SizedBox(
                  height: constraints.maxHeight * 0.02,
                )),
                SizedBox(
                    height: 400,
                    width: constraints.maxWidth * 0.9,
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
                        child: Center(
                          child: Column(
                            children: [
                              const Center(
                                  child: SizedBox(
                                height: 40,
                              )),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              const Text(
                                "family history",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  const Text("parent state"),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  DropdownButton<String>(
                                    value: dropdownValueParentState,
                                    icon: const Icon(
                                        Icons.arrow_drop_down_circle_outlined),
                                    elevation: 10,
                                    style: const TextStyle(
                                        color: Colors.deepPurple),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        dropdownValueParentState = value!;
                                      });
                                    },
                                    items: listParentState
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  const Text("number of sibling"),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Center(
                                      child: SizedBox(
                                    width: 20,
                                    child: TextField(
                                      controller: numberOfSiblingController,
                                      keyboardType: TextInputType.number,
                                      decoration:
                                          const InputDecoration(hintText: '0'),
                                    ),
                                  )),
                                ],
                              ),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Center(
                                      child: SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: ageFatherController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          hintText: 'age of the father'),
                                    ),
                                  )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Center(
                                      child: SizedBox(
                                    width: 110,
                                    child: TextField(
                                      controller: workFatherController,
                                      decoration: const InputDecoration(
                                          hintText: 'profession of the father'),
                                    ),
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Center(
                                      child: SizedBox(
                                    width: 130,
                                    child: TextField(
                                      controller: ageMotherController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          hintText: 'age of the mother'),
                                    ),
                                  )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Center(
                                      child: SizedBox(
                                    width: 110,
                                    child: TextField(
                                      controller: workMotherController,
                                      decoration: const InputDecoration(
                                          hintText: 'profession of the mother'),
                                    ),
                                  )),
                                ],
                              ),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              SizedBox(
                                  height: 30,
                                  width: 70,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        DatabaseReference ref =
                                            FirebaseDatabase.instance.ref(
                                                "patientfiles/${widget.patientId}/family_history");

                                        await ref.set({
                                          "father_age":
                                              ageFatherController.text,
                                          "mother_age":
                                              ageMotherController.text,
                                          "number_of_siblings":
                                              numberOfSiblingController.text,
                                          "parent_status":
                                              dropdownValueParentState,
                                          "father_profession":
                                              workFatherController.text,
                                          "mother_profession":
                                              workMotherController.text,
                                        });
                                      },
                                      child: const Text("save")))
                            ],
                          ),
                        ))),
                Center(
                    child: SizedBox(
                  height: constraints.maxHeight * 0.02,
                )),
                SizedBox(
                    height: constraints.maxHeight * 0.5,
                    width: constraints.maxWidth * 0.9,
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
                        child: Center(
                          child: Column(
                            children: [
                              const Center(
                                  child: SizedBox(
                                height: 40,
                              )),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              const Text(
                                "psycological evaluation",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              ),

                              Center(
                                  child: SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: relationshipIssuesController,
                                  decoration: const InputDecoration(
                                      hintText: 'relationship issues'),
                                ),
                              )),
                              const SizedBox(
                                width: 20,
                              ),
                              Center(
                                  child: SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: healthIssuesController,
                                  decoration: const InputDecoration(
                                      hintText: 'health issues'),
                                ),
                              )),
                              Center(
                                  child: SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: ecoSocialIssuesController,
                                  decoration: const InputDecoration(
                                      hintText: 'social-economical issues'),
                                ),
                              )),
                              Center(
                                  child: SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: familyProblemsController,
                                  decoration: const InputDecoration(
                                      hintText: 'family problems'),
                                ),
                              )),
                              const Center(
                                  child: SizedBox(
                                height: 10,
                              )),
                              SizedBox(
                                  height: 30,
                                  width: 70,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        DatabaseReference ref =
                                            FirebaseDatabase.instance.ref(
                                                "patientfiles/${widget.patientId}/psycological_evaluation");

                                        await ref.set({
                                          "relationship_issues":
                                              relationshipIssuesController.text,
                                          "health_issues":
                                              healthIssuesController.text,
                                          "social_eco_issues":
                                              ecoSocialIssuesController.text,
                                          "family_issues":
                                              familyProblemsController.text,
                                        });
                                      },
                                      child: const Text("save")))
                            ],
                          ),
                        ))),
                Center(
                    child: SizedBox(
                  height: constraints.maxHeight * 0.02,
                )),
              ],
            ));
          }));
      // Your initialization for material app.
    }));
  }
  Future<void> onJoinqtcarevideocall(String patientId, String patientName) async {
    // update input validation

    sendPushNotification(_fcmPatient,'video call invitation',"your therapist has joined the appointment, please join him in less than 5mins ");


    Future<String> createAndSaveToken(String patientId, String patientName) async {
      final database = FirebaseDatabase.instance.ref();

      final uri =
      Uri.parse('${AppUrls.getVideoChatTokenUrl}$patientName/audience/uid/0');
      http.Response response = await http.get(uri);
      final Map<String, dynamic> data = json.decode(response.body);



      DatabaseReference ref =
      FirebaseDatabase.instance.ref("appointment_room/$patientId");
      await ref.update({
        "videocalltoken": data["rtcToken"],
      });
      print(data["rtcToken"]);


      return data["rtcToken"];
    }

    String token = await createAndSaveToken(patientId,patientName);
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);

    // push video page with given channel name
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  CallWidget(
          channelName: patientName,
          patientId:
          widget.patientId,
          token: token,
          role: ClientRole.Broadcaster,
        ),
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
  Future<String> createAndSaveToken(String patientId, String patientName) async {
    final database = FirebaseDatabase.instance.ref();

    final uri =
    Uri.parse('${AppUrls.getVideoChatTokenUrl}$patientName/audience/uid/0');
    http.Response response = await http.get(uri);
    final Map<String, dynamic> data = json.decode(response.body);



      DatabaseReference ref =
      FirebaseDatabase.instance.ref("appointment_room/$patientId");
      await ref.update({
        "videocalltoken": data["rtcToken"],
      });
      print(data["rtcToken"]);


    return data["rtcToken"];
  }

}
