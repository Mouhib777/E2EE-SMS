import 'package:flutter/material.dart';
import 'package:sms_encry/screens/smsMessage.dart';

class SmsListScreen extends StatefulWidget {
  @override
  _SmsListScreenState createState() => _SmsListScreenState();
}

class _SmsListScreenState extends State<SmsListScreen> {
  List<SmsMessage> smsMessages = [];

  @override
  Widget build(BuildContext context) {
    // Build the UI for displaying the SMS list
    return Scaffold(
      appBar: AppBar(
        title: Text('SMS List'),
      ),
      body: ListView.builder(
        itemCount: smsMessages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(smsMessages[index].sender),
            subtitle: Text(smsMessages[index].messageBody),
          );
        },
      ),
    );
  }
}
