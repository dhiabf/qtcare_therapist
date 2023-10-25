

class messageModel {
  late String messagetime;
  late String sender;
  late String content;



  messageModel({
    required this.messagetime,
    required this.sender,
    required this.content,



  });

  static messageModel fromMap(Map<String,dynamic> map){
    return messageModel(
      messagetime: map['messagetime'],
      sender: map['sender'],
      content: map['content'],

    );
  }



}