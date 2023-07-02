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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All SMS"),
        centerTitle: true,
      ),
    );
  }
}
