import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:qtcare_therapist/constants.dart';

class NewCallVersion extends StatefulWidget {
  final String channelName;
  final String token;

  const NewCallVersion(
      {Key? key, required this.channelName, required this.token})
      : super(key: key);

  @override
  State<NewCallVersion> createState() => _MyAppState();
}

class _MyAppState extends State<NewCallVersion> {
  late AgoraClient client;

  @override
  void initState() {
    super.initState();
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: Constants.agoraAppId,
        channelName: "test",
        tempRtmToken: "006be7369c2f93a4a24b92fdd2489202253IAA0vC7Naor7VNiTk2DdmYfXuLy2tQ5MHnfevO7ODar2c0ngOggAAAAAIgA+AjGeqApsZAQAAQAQDgAAAgAQDgAAAwAQDgAABAAQDgAA",
      ),
    );
    initAgora();
  }

  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: client,
                layoutType: Layout.floating,
                enableHostControls: true, // Add this to enable host controls
              ),
              AgoraVideoButtons(
                autoHideButtons: true,
                autoHideButtonTime: 5,
                client: client,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
