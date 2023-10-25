
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


void GetPatientsid() async {

  final List<String> patientsid = [];
  final User user = FirebaseAuth.instance.currentUser!;
  final String uid = user.uid.toString();




  print(patientsid);
  final uri = await Uri.parse('http://qtcare-healthapp-default-rtdb.firebaseio.com/therapists/$uid');

  http.Response response = await http.get(uri);
  print(response.statusCode);
  if (response.statusCode == 200) {
    String data = response.body;
    print(data);
  } else {}

}