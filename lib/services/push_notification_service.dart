

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:qtcare_therapist/core/utils/app_url.dart';




Future<void> sendPushNotification(String fcmToken, String title,String message ) async {
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=${AppUrls.fcmServerKey}',
  };

  Map<String, dynamic> body = {
    'notification': {
      'title': title,
      'body': message,
    },
    'to': fcmToken,
  };
  Uri url = Uri.parse(AppUrls.fcmSendPushNotificationUrl);
  http.Response response = await http.post(
    url,
    headers: headers,
    body: json.encode(body),
  );
}