import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qtcare_therapist/callandroid.dart';
import 'package:qtcare_therapist/core/utils/app_url.dart';
import 'package:qtcare_therapist/services/push_notification_service.dart';
import 'package:qtcare_therapist/therapist_calendar.dart';
import 'package:http/http.dart' as http;



class Singleappointementwidget extends StatefulWidget {

  final String? patientname;
  final String? patientid;
  final String? patientpicture;
  final String? eventdescription;
  final String? appointementid;


  const Singleappointementwidget(BuildContext context, {Key? key, this.patientname, this.patientpicture, this.eventdescription, this.appointementid, this.patientid}) : super(key: key);

  @override
  _SingleappointementwidgetState createState() => _SingleappointementwidgetState();
}

class _SingleappointementwidgetState extends State<Singleappointementwidget> {

  String appointementstate="";
  String ConfirmOrJoinbutton="confirm"
  ;
  bool hideconfirmorjoinbutton=true;
  Color confirmorjoinbutton = Colors.orange;
  Future<void> _getappointementstate() async {
    DatabaseReference appointementref = FirebaseDatabase.instance.ref("appointments/${widget.appointementid}/state");
    DatabaseEvent eventappointement = await appointementref.once();
    appointementstate=eventappointement.snapshot.value.toString();
    if (appointementstate=="confirmed"){
      ConfirmOrJoinbutton="join";
    }
    if (appointementstate=="cancelled"){
      hideconfirmorjoinbutton=false;
      confirmorjoinbutton= Colors.orange;
    }
    if (appointementstate=="waiting"){
      confirmorjoinbutton= Colors.green;
    }



    setState(() {});


  }

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
  void initState(){
    _getPatientFcm();
    super.initState();
    _getappointementstate();
  }




  @override
  Widget build(BuildContext context) {
    // Figma Flutter Generator ProfilepageWidget - FRAME

    return  Container(

            child: Stack(
                children: <Widget>[
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                          width: 250,
                          height: 210,
                          decoration: BoxDecoration(

                          ),
                          child: Stack(
                              children: <Widget>[

                                Positioned(
                                    top: 267,
                                    left: 0,
                                    child: Container(
                                        width: 500,
                                        height: 457,
                                        decoration: BoxDecoration(

                                        ),
                                        child: Stack(
                                            children: <Widget>[

                                              Positioned(
                                                  top: 193,
                                                  left: 57,
                                                  child: Container(
                                                      width: 238,
                                                      height: 156,
                                                      decoration: BoxDecoration(
                                                        borderRadius : BorderRadius.only(
                                                          topLeft: Radius.circular(31),
                                                          topRight: Radius.circular(31),
                                                          bottomLeft: Radius.circular(31),
                                                          bottomRight: Radius.circular(31),
                                                        ),

                                                      )
                                                  )
                                              ),
                                            ]
                                        )
                                    )
                                ),
                              ]
                          )
                      )
                  ),

                  Positioned(
                      top: 96,
                      left: 33,
                      child: Container(
                          width: 400,
                          height: 149,

                          child: Stack(
                              children: <Widget>[

                                Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                        width: 300,
                                        height: 149,
                                        decoration: BoxDecoration(
                                          borderRadius : BorderRadius.only(
                                            topLeft: Radius.circular(35),
                                            topRight: Radius.circular(35),
                                            bottomLeft: Radius.circular(35),
                                            bottomRight: Radius.circular(35),
                                          ),
                                          boxShadow : [BoxShadow(
                                              color: Color.fromRGBO(150, 156, 156, 0.8999999761581421),
                                              offset: Offset(1,1),
                                              blurRadius: 3
                                          )],
                                          gradient : LinearGradient(
                                              begin: Alignment(0.5,0.5),
                                              end: Alignment(-0.5,0.5),
                                              colors: [Color.fromRGBO(246, 255, 255, 1),Color.fromRGBO(222, 231, 232, 1)]
                                          ),
                                        )
                                    )
                                ),


                                Positioned(
                                    top: 20,
                                    left: 117,
                                    child: Text("${widget.patientname}", textAlign: TextAlign.left, style: TextStyle(
                                        color: Color.fromRGBO(0, 0, 0, 1),
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.bold,
                                        height: 1
                                    ),)
                                ),

                                Positioned(
                                    top: 40,
                                    left: 117,
                                    child: SizedBox(width: 150,child: Text("${widget.eventdescription}", textAlign: TextAlign.left, style: TextStyle(
                                        color: Color.fromRGBO(0, 0, 0, 1),
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1
                                    ),),)
                                ),
                                Positioned(
                                    top: 100,
                                    left: 105,
                                    child:
                                    Visibility(
                                        visible: hideconfirmorjoinbutton,
                                        child:

                                    SizedBox(width: 85,child: ElevatedButton(

                                      style: ElevatedButton.styleFrom(
                                        primary: confirmorjoinbutton
                                        , // Background color
                                      ),
                                      onPressed: () async {
                                        sendPushNotification(_fcmPatient,'video call invitation',"your therapist has joined the appointment, please join him in less than 5mins ");

                                        String token = await createAndSaveToken(widget.patientid.toString(), widget.patientname.toString());
                                        if (appointementstate=="waiting"){
                                          print("to aprove");
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible: false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('appointment confirmation'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: const <Widget>[
                                                      Text('you are about to confirm this appointment'),
                                                      Text('are you sure about this?'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('cancel',
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();

                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('confirm?',

                                                    ),
                                                    onPressed: () async {
                                                      sendPushNotification(_fcmPatient,"Request approved ","your therapist accepted your video call request");

                                                      DatabaseReference refappointement = FirebaseDatabase.instance.ref("appointments/${widget.appointementid}");
                                                      await refappointement.update({
                                                        "state": "confirmed",
                                                      });
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => CalendarWidget(),
                                                        ),
                                                      )  ;
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                        else if (appointementstate=="confirmed"){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>  CallWidget(
                                                channelName: widget.patientname,
                                                patientId:
                                                widget.patientid,
                                                token: token,
                                                role: ClientRole.Broadcaster,
                                              ),
                                            ),
                                          );

                                        }

                                        /*DatabaseReference refappointement = FirebaseDatabase.instance.ref("appointments/${widget.appointementid}");
                                        await refappointement.update({
                                          "state": "confirmed",
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => calendar(),
                                          ),
                                        )  ;*/
                                        setState(() {

                                        });



                                      },
                                    child: Text(ConfirmOrJoinbutton),),))
                                ),
                                Positioned(
                                    top: 100,
                                    left: 195,
                                    child:
                                        Visibility(
                                            visible: hideconfirmorjoinbutton,
                                            child:
                                    SizedBox(width: 80,child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.redAccent, // Background color
                                      ),
                                      onPressed: () async {
                                        sendPushNotification(_fcmPatient,"Request not approved ","your therapist is not available at the time you requested, please try another date");


                                        DatabaseReference refappointement = FirebaseDatabase.instance.ref("appointments/${widget.appointementid}");
                                        await refappointement.update({

                                          "state": "cancelled",
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CalendarWidget(),
                                          ),
                                        )  ;



                                        setState(() {

                                        });
                                      },
                                      child: Text("cancel",
                                        style: TextStyle(fontSize: 10),
                                      ),),))
                                ),




                              ]
                          )
                      )
                  ),Positioned(
                      top: 76,
                      left: 33,
                      child: Container(
                          width: 104,
                          height: 140,

                          child: Stack(
                              children: <Widget>[
                                Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                        width: 104,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          borderRadius : BorderRadius.only(
                                            topLeft: Radius.circular(40),
                                            topRight: Radius.circular(40),
                                            bottomLeft: Radius.circular(40),
                                            bottomRight: Radius.circular(40),
                                          ),
                                          boxShadow : [BoxShadow(
                                              color: Color.fromRGBO(189, 189, 189, 0.8999999761581421),
                                              offset: Offset(1,1),
                                              blurRadius: 3
                                          )],
                                          gradient : LinearGradient(
                                              begin: Alignment(0.5,0.5),
                                              end: Alignment(-0.5,0.5),
                                              colors: [Color.fromRGBO(22, 151, 153, 1),Color.fromRGBO(139, 197, 173, 1)]
                                          ),
                                        )
                                    )
                                ),

                              ]
                          )
                      )
                  ),
                  Positioned(
                    top: 80,
                    left: 35,
                    child: SizedBox(
                        height: 100,
                        width: 100,
                        child:new Image.asset(
                          "${widget.patientpicture}",
                          height: 100,
                          width: 100,
                        )),


                  ),
                ]
            )
        );
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
