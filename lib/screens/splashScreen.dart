import 'dart:async';

import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  final Telephony telephony = Telephony.instance;
  @override
  void initState() {
    Timer(
        Duration(
          seconds: 3,
        ), () async {
      await telephony.requestPhoneAndSmsPermissions;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    );
  }
}
