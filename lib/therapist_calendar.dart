import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:qtcare_therapist/patients_listview.dart';
import 'package:qtcare_therapist/single_appointement_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';
import 'dashboard_homepage.dart';
import 'data/eventdata.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        theme: ThemeData.from(
          colorScheme: const ColorScheme.light(),
        ).copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
            },
          ),
        ),
        home:  const TherapistCalendar());
  }
}

class TherapistCalendar extends StatefulWidget {
  const TherapistCalendar({
    Key? key,
  }) : super(key: key);

  @override
  _TherapistCalendarState createState() => _TherapistCalendarState();
}

class _TherapistCalendarState extends State<TherapistCalendar> {
  DateTime _day = DateTime.now();

  Map<dynamic, dynamic> items = {};
  List appointements = [];
  List<CalendarEventData<Event>> _events = [];
  String patientname = "";
  String patientpicture = "";

  Future<void> _getappointements() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("appointments");

    final User user = FirebaseAuth.instance.currentUser!;
    final String uid = user.uid.toString();

    Query query = ref.orderByChild("therapistid").equalTo(uid);
    DataSnapshot event = await query.get();
    items = event.value as Map;
    appointements = items.values.toList();
    print(appointements);
    appointements.forEach((element) async {
      String patient = element["userid"];
      DatabaseReference patientref =
          FirebaseDatabase.instance.ref("users/$patient/pseudoname");
      DatabaseEvent eventpatient = await patientref.once();
      String patientname = eventpatient.snapshot.value.toString();

      DatabaseReference patientavatar =
          FirebaseDatabase.instance.ref("users/$patient/avatarurl");
      DatabaseEvent eventpatientavatar = await patientavatar.once();
      String patientpicture = eventpatientavatar.snapshot.value.toString();
      print(patientname);
      String calltime = element["time"].toString();
      String appointement_state = element["state"];
      String appointement_state2 = "";
      Color elementcolor = Colors.blue;
      if (appointement_state == "waiting") {
        appointement_state2 =
            "the requested call at $calltime is waiting for confirmation";
        elementcolor = Colors.yellow;
      }
      ;
      if (appointement_state == "cancelled") {
        appointement_state2 = "the rquest was cancelled";
        elementcolor = Colors.red;
      }
      ;
      if (appointement_state == "confirmed") {
        appointement_state2 = "the requested call at $calltime is confirmed";
        elementcolor = Colors.green;
      }
      ;
      setState(() {});

      String time = element["time"].toString();
      String seconds = time.split(':').last;
      String hours = time.split(':').first;
      String timeofday = seconds.substring(3, 5);
      seconds = seconds.substring(0, 2);
      print(seconds);
      print(timeofday);
      int hourofday = int.parse(hours);
      if (timeofday == "PM") {
        hourofday = hourofday + 12;
        print(hourofday);
      }
      if (element["state"] != "cancelled") {
        _events.add(
          CalendarEventData(
            date: DateTime(int.parse(element["year"]),
                int.parse(element["month"]), int.parse(element["day"])),
            color: elementcolor,
            startTime: DateTime(
                int.parse(element["year"]),
                int.parse(element["month"]),
                int.parse(element["day"]),
                hourofday,
                int.parse(seconds)),
            endTime: DateTime(
                int.parse(element["year"]),
                int.parse(element["month"]),
                int.parse(element["day"]),
                hourofday + 2,
                int.parse(seconds.substring(0, 1))),
            event: Event(title: "video session"),
            title: "video session with $patientname",
            description: appointement_state2,
          ),
        );
      }
      ;
    });
    setState(() {});
  }

  @override
  void dispose() {
    dispose();
    super.dispose();
  }

  bool hidecalendartuto = false;

  Future<void> gethidetutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? hidecalendartuto1 = prefs.getBool('hidecalendartuto');
    setState(() {
      hidecalendartuto = hidecalendartuto1!;
    });
    if (hidecalendartuto == false) {
      WidgetsBinding.instance.addPostFrameCallback(_showOpenDialog);
      print("shown tuto");
    }
  }

  @override
  void initState() {
    super.initState();
    gethidetutorial();
    print(hidecalendartuto);
    _getappointements();

    // initialize agora sdk
  }

  _showOpenDialog(_) {
    showDialog(
        context: context,
        builder: (context) {
          return Material(
              color: Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                color: Color.fromRGBO(0, 0, 0, 0),
                width: 200,
                height: 500,
                child: PageView(
                  children: <Widget>[
                    Center(
                        child: Container(
                      width: 300,
                      height: 500,
                      decoration: BoxDecoration(
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
                          SizedBox(
                            height: 20,
                          ),
                          Text("information"),
                          SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                              width: 150,
                              height: 150,
                              child: Lottie.network(
                                  'https://assets4.lottiefiles.com/temporary_files/n1DHEu.json')),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 40,
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text("waiting to be confirmed"),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 40,
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text("confirmed appointements"),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 40,
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text("cancelled appointements"),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                              width: 40,
                              height: 40,
                              child: Image.asset('assets/vectors/left.png'))
                        ],
                      ),
                    )),
                    Center(
                        child: Container(
                      width: 300,
                      height: 500,
                      decoration: BoxDecoration(
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
                          SizedBox(
                            height: 20,
                          ),
                          Text("information"),
                          SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                              width: 150,
                              height: 150,
                              child: Lottie.network(
                                  'https://assets4.lottiefiles.com/packages/lf20_7rwxhdcs.json')),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.greenAccent),
                                  ),
                                  onPressed: () {},
                                  child: Text("weekview")),
                              SizedBox(
                                width: 5,
                              ),
                              Text("navigate to week view"),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blueGrey),
                                  ),
                                  onPressed: () {},
                                  child: Text("dayview")),
                              SizedBox(
                                width: 5,
                              ),
                              Text("navigate to day view"),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blueGrey),
                                  ),
                                  onPressed: () {},
                                  child: Text("monthview")),
                              SizedBox(
                                width: 5,
                              ),
                              Text("navigate to month view"),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Transform.scale(
                                  scaleX: -1,
                                  child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset(
                                          'assets/vectors/left.png'))),
                              SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Image.asset('assets/vectors/left.png'))
                            ],
                          )
                        ],
                      ),
                    )),
                    Center(
                        child: Container(
                      width: 300,
                      height: 500,
                      decoration: BoxDecoration(
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
                          SizedBox(
                            height: 20,
                          ),
                          Text("information"),
                          SizedBox(
                            height: 40,
                          ),
                          CircleAvatar(
                            child: ClipOval(
                                child: Image.asset(
                                    'assets/vectors/monthicon.png')),
                          ),
                          SizedBox(
                              width: 40,
                              height: 40,
                              child:
                                  Image.asset('assets/vectors/monthicon.png')),
                          SizedBox(
                              width: 40,
                              height: 40,
                              child:
                                  Image.asset('assets/vectors/eventicon.png')),
                          SizedBox(
                              width: 200,
                              height: 150,
                              child: Image.asset(
                                  'assets/vectors/eventconfirmicon.png')),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blueGrey),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("hide")),
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blueAccent),
                                  ),
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool(
                                        'hidecalendartuto', true);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("never show again")),
                            ],
                          )
                        ],
                      ),
                    )),
                  ],
                ),
              ));
        });
  }

  bool _monthbuttonselected = true;
  Color buttondaycolor = Colors.blueGrey;
  Color buttonmonthcolor = Colors.greenAccent;
  Color buttonweekcolor = Colors.blueGrey;

  bool _weekbuttonselected = false;
  bool _daybuttonselected = false;
  bool _showpickertrue = false;
  String _pickerbuttontext = "show date picker";

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider<Event>(
      controller: EventController<Event>()..addAll(_events),
      child: MaterialApp(
          theme: ThemeData.from(
            colorScheme: const ColorScheme.light(),
          ).copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
              },
            ),
          ),
          home: Scaffold(
              appBar: AppBar(
                backgroundColor: appBarColor,
                title: Text('Your calendar'),
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
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientView(),
                                ),
                              )),
                    ),
                    Padding(
                      padding: tilePadding,
                      child: ListTile(
                        leading: Icon(Icons.info),
                        title: Text(
                          'C A L E N D E R',
                          style: drawerTextColor,
                        ),
                        onTap: () => CalendarWidget(),
                      ),
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
              body: LayoutBuilder(builder: (context, constraints) {
                return Column(
                  children: [
                    Container(
                      height: constraints.maxHeight * 0.05,
                      decoration: const BoxDecoration(
                        color: Colors.blueGrey,
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                              'learn how to use your calendar by clicking here',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          IconButton(
                            onPressed: () {
                              WidgetsBinding.instance
                                  .addPostFrameCallback(_showOpenDialog);
                            },
                            icon: Icon(Icons.info),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: constraints.maxHeight * 0.1,
                      decoration: const BoxDecoration(
                        color: Colors.lightGreen,
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(buttondaycolor),
                              ),
                              onPressed: () {
                                setState(() {
                                  buttondaycolor = Colors.greenAccent;
                                  buttonmonthcolor = Colors.blueGrey;
                                  buttonweekcolor = Colors.blueGrey;

                                  _monthbuttonselected = false;
                                  _daybuttonselected = true;
                                });
                              },
                              child: Text("dayview")),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(buttonmonthcolor),
                              ),
                              onPressed: () {
                                setState(() {
                                  buttondaycolor = Colors.blueGrey;
                                  buttonmonthcolor = Colors.greenAccent;
                                  buttonweekcolor = Colors.blueGrey;
                                  _monthbuttonselected = true;
                                  _daybuttonselected = false;
                                });
                              },
                              child: Text("monthview")),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(buttonweekcolor),
                              ),
                              onPressed: () {
                                setState(() {
                                  buttondaycolor = Colors.blueGrey;
                                  buttonmonthcolor = Colors.blueGrey;
                                  buttonweekcolor = Colors.greenAccent;
                                });
                              },
                              child: Text("weekview")),
                        ],
                      ),
                    ),
                    if (_monthbuttonselected)
                      SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight * 0.85,
                        child: MonthView<Event>(
                          cellAspectRatio: 0.4,
                          borderSize: 0.4,
                          onEventTap: (_events, date) async {
                            _getappointements();
                            _daybuttonselected = true;
                            _monthbuttonselected = false;
                            setState(() {
                              _day = date;
                            });
                            print(_events);
                            print(date);
                          },

                          /*controller: EventController<Event>()..addAll(_events),
                        // to provide custom UI for month cells.
                        cellBuilder: (date, _events, isToday, isInMonth) {
                          // Return your widget to display as month cell.
                          return Container(child: Text(date.day.toString()),);
                        },
                        minMonth: DateTime(1990),
                        maxMonth: DateTime(2050),
                        initialMonth: DateTime.now(),
                        cellAspectRatio: 1,
                        onPageChange: (date, pageIndex) => print("$date, $pageIndex"),
                        onCellTap: (_events, date) async {
                          _daybuttonselected=true;
                          _monthbuttonselected=false;
                          setState((){
                            _day=date;

                          });
                          print(_events);

                          print(date);
                        },
                        startDay: WeekDays.sunday, // To change the first day of the week.
                        // This callback will only work if cellBuilder is null.
                        onEventTap: (event, date) {

                        },

                        onDateLongPress: (date) => print(date),
                      */
                        ),
                      ),
                    if (_daybuttonselected)
                      Center(
                        child: SizedBox(
                          width: constraints.maxWidth * 1,
                          height: constraints.maxHeight * 0.85,
                          child: DayView<Event>(
                              initialDay: _day,
                              showVerticalLine: true,
                              // To display live time line in day view.
                              heightPerMinute: 1,
                              backgroundColor: Colors.white54,
                              // height occupied by 1 minute time span.
                              onEventTap: (event, date) async {
                                final dateFormatter = DateFormat('hh:mm a');
                                print(event[0].startTime);
                                String dateString = dateFormatter
                                    .format(event[0].startTime as DateTime)
                                    .toString();

                                //print(event[0].date.day);
                                //print(event[0].date.month);
                                //print(event[0].date.year);

                                DatabaseReference ref = FirebaseDatabase
                                    .instance
                                    .ref("appointments");

                                final User user =
                                    FirebaseAuth.instance.currentUser!;
                                final String uid = user.uid.toString();
                                List appointements = [];
                                String patientid = "";

                                Query query = ref
                                    .orderByChild("therapistid")
                                    .equalTo(uid);

                                DataSnapshot eventappointement =
                                    await query.get();
                                items = eventappointement.value as Map;
                                appointements = items.keys.toList();
                                String thisappointement = "";
                                int i = 0;
                                items.values.forEach((element) async {
                                  String appointement = appointements[i];
                                  String timecheck = element["time"].toString();
                                  String accuratetime = dateString;
                                  if (dateString.length != timecheck.length) {
                                    accuratetime = dateString.substring(1);
                                  }
                                  print(element["time"]);
                                  print(accuratetime);

                                  i = i + 1;
                                  if (element["month"] ==
                                      event[0].date.month.toString()) {
                                    if (element["day"] ==
                                        event[0].date.day.toString()) {
                                      if (element["year"] ==
                                          event[0].date.year.toString()) {
                                        if (element["time"] == accuratetime) {
                                          thisappointement = appointement;
                                          patientid = element["userid"];
                                          setState(() {});
                                        }
                                      }
                                    }
                                  }
                                });
                                print(thisappointement);
                                print(patientid);
                                DatabaseReference patientimageref =
                                    FirebaseDatabase.instance
                                        .ref("users/$patientid/avatarurl");
                                DatabaseEvent eventpatientpicture =
                                    await patientimageref.once();
                                patientpicture = eventpatientpicture
                                    .snapshot.value
                                    .toString();
                                print(patientpicture);

                                setState(() {});

                                appointements.forEach((element) async {});

                                setState(() {});
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      Singleappointementwidget(
                                    context,
                                    patientname: event[0].title,
                                    appointementid: thisappointement,
                                    eventdescription: event[0].description,
                                    patientpicture: patientpicture,
                                        patientid: patientid,

                                      ),
                                );

                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Singleappointementwidget(
                                      patientname: event[0].title,
                                      eventdescription: event[0].description,
                                      patientpicture: patientpicture,
                                    ),
                                  ),
                                );*/
                              }
                              /*controller: EventController<Event>()..addAll(_events),
                        eventTileBuilder: (date, events, boundry, start, end) {
                          // Return your widget to display as event tile.
                          return Container();
                        },
                        showVerticalLine: true, // To display live time line in day view.
                        showLiveTimeLineInAllDays: true, // To display live time line in all pages in day view.
                        minDay: DateTime(1990),
                        maxDay: DateTime(2050),
                        initialDay: _day,
                        heightPerMinute: 1.5, // height occupied by 1 minute time span.
                        eventArranger: SideEventArranger(), // To define how simultaneous events will be arranged.
                        onEventTap: (events, date) => print(events),
                        onDateLongPress: (date) => print(date),*/
                              ),
                        ),
                      ),
                  ],
                );
              }))
          // Your initialization for material app.
          ),
    );
  }
}
