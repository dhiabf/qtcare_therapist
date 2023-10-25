
import 'form_status.dart';

class LoginState {
  final String username;
  bool get isValidUsername => username.length > 3;

  final String password;
  bool get isValidPassword => password.length > 6;
  bool emailnotfound;
  final FormSubmissionStatus formStatus;

  LoginState({
    this.emailnotfound=false,
    this.username = '',
    this.password = '',
    this.formStatus = const InitialFormStatus(),
  });

  LoginState copyWith({
    String? username,
    String? password,
    bool? emailnotfound,
    FormSubmissionStatus? formStatus,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      formStatus: formStatus ?? this.formStatus,
      emailnotfound: emailnotfound ?? this.emailnotfound,
    );
  }
}