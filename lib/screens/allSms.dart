import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:sms_advanced/sms_advanced.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class allSms extends StatefulWidget {
  const allSms({super.key});

  @override
  State<allSms> createState() => _allSmsState();
}

class _allSmsState extends State<allSms> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];

  @override
  void initState() {
    super.initState();
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
        child: _messages.isNotEmpty
            ? _MessagesListView(
                messages: _messages,
              )
            : Center(
                child: InkWell(
                  child: Text(
                    'No messages to show.',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                    // style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  onLongPress: () async {
                    var permission = await Permission.sms.status;
                    if (permission.isGranted) {
                      final messages = await _query.querySms(
                        kinds: [
                          SmsQueryKind.inbox,
                          SmsQueryKind.sent,
                        ],
                        // address: '+254712345789',
                        count: 10,
                      );
                      debugPrint('sms inbox messages: ${messages.length}');

                      setState(() => _messages = messages);
                    } else {
                      await Permission.sms.request();
                    }
                  },
                ),
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

        return ListTile(
          title: Text(
              '${message.sender} ${message.date!.hour}h:${message.date!.minute}'),
          subtitle: Text('${message.body}'),
        );
      },
    );
  }
}
