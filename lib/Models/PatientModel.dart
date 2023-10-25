

class PatientModel {
  String? pseudoname;
  String? email;
  String? avatar;



  PatientModel({
    required this.pseudoname,
    required this.email,
    required this.avatar});




  static PatientModel fromMap(Map<String,dynamic> map){
    return PatientModel(
      pseudoname: map['pseudoname'],
      email: map['email'],
      avatar: map['avatar'],
    );
  }
}