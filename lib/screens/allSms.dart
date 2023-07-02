import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';

class allSms extends StatefulWidget {
  const allSms({super.key});

  @override
  State<allSms> createState() => _allSmsState();
}

class _allSmsState extends State<allSms> {
  final SmsQuery query = SmsQuery();
  List<SmsMessage> messages = [];
  @override
  void initState() {
    super.initState();
    fetchSMSMessages();
  }

  void fetchSMSMessages() async {
    messages = await query.getAllSms;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All SMS"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                minVerticalPadding: 8,
                minLeadingWidth: 4,
                title: Text(messages[index].body ?? 'empty'),
                subtitle: Text(messages[index].address ?? 'empty'),
              ),
              const Divider()
            ],
          );
        },
      ),
    );
  }
}
