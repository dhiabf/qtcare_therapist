import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qtcare_therapist/therapist_calendar.dart';

var defaultBackgroundColor = Colors.grey[300];
var appBarColor = Colors.grey[900];
var myAppBar = AppBar(
  backgroundColor: appBarColor,
  title: Text('Qtcare therapist dashboard'),
  centerTitle: false,
);
var drawerTextColor = TextStyle(
  color: Color.fromRGBO(22, 28, 21, 1.0),
);
var tilePadding = const EdgeInsets.only(left: 8.0, right: 8, top: 8);