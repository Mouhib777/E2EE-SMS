import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'dart:async';

import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sms_encry/screens/decryptionPage.dart';

class AllSms extends StatefulWidget {
  const AllSms({Key? key});

  @override
  State<AllSms> createState() => _AllSmsState();
}

class _AllSmsState extends State<AllSms> {
  final SmsQuery _query = SmsQuery();
  StreamController<List<SmsMessage>> _smsStreamController =
      StreamController<List<SmsMessage>>();
  Stream<List<SmsMessage>>? _smsStream;

  @override
  void initState() {
    super.initState();
    _smsStream = _smsStreamController.stream;
    _loadSmsMessages();
  }

  @override
  void dispose() {
    _smsStreamController.close();
    super.dispose();
  }

  Future<void> _loadSmsMessages() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [
          SmsQueryKind.inbox,
          SmsQueryKind.sent,
        ],
      );
      _smsStreamController.add(messages);
    } else {
      await Permission.sms.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMS Messages'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<List<SmsMessage>>(
          stream: _smsStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return _MessagesListView(messages: snapshot.data!);
            } else {
              return Center(
                child: InkWell(
                  child: Text(
                    'No messages to show.',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  onLongPress: _loadSmsMessages,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _MessagesListView extends StatelessWidget {
  const _MessagesListView({
    Key? key,
    required this.messages,
  }) : super(key: key);

  final List<SmsMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => Divider(),
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int i) {
        var message = messages[i];

        return InkWell(
          onDoubleTap: () {
            pushNewScreenWithRouteSettings(context,
                screen: decryptionPage(),
                settings: RouteSettings(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino);
          },
          child: ListTile(
            title: Text(
              '${message.sender} ${message.date!.hour}h:${message.date!.minute}',
            ),
            subtitle: Text('${message.body}'),
          ),
        );
      },
    );
  }
}
