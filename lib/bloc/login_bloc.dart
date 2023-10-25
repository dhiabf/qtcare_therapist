import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../callandroid.dart';
import '../callweb.dart';
import '../dashboard_homepage.dart';
import '../event/login_event.dart';
import '../states/login_state.dart';
import 'auth_repo.dart';




class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepo;

  String _username ="";
  String _password="";
  bool _emailnotfound =false;


  LoginBloc({required this.authRepo}) : super(LoginState()){
    on<LoginPasswordChanged>(_handleLoginPasswordChanged);
    on<LoginUsernameChanged>(_handleLoginUsernameChanged);
    on<LoginSubmitted>(_handleLoginSubmitted);
  }

  Future<void> _handleLoginSubmitted( LoginSubmitted event, Emitter<LoginState> emit,) async {
  print("here");
  print(_username);
  print(_password);


    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: _username, password: _password).then((value) => Get.to(() =>CallWidget()));
    }
    catch(e){
      state.emailnotfound =true;
      print(e);
      print(state.emailnotfound);
      emit(LoginState(emailnotfound: state.emailnotfound));

    }




  }



  Future<void> _handleLoginPasswordChanged(LoginPasswordChanged event,Emitter<LoginState> emit,) async {
    emit(LoginState(password: event.password));
    _password=event.password;
  }


  Future<void> _handleLoginUsernameChanged(LoginUsernameChanged event, Emitter<LoginState> emit,) async {
    emit(LoginState(username: event.username));
    _username = event.username;

  }


  @override
  void dispose() {
  }
}
