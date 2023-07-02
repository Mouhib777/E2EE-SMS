import 'package:flutter/material.dart';

class allSms extends StatefulWidget {
  const allSms({super.key});

  @override
  State<allSms> createState() => _allSmsState();
}

class _allSmsState extends State<allSms> {
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
