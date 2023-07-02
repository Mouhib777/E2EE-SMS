import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  // final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    Timer(
        Duration(
          seconds: 1,
        ), () async {
      // const platform = const MethodChannel("com.example.chat/chat");
      // try {
      //   final result = await platform.invokeMethod('setDefaultSms');
      //   print("Result: $result");
      // } on PlatformException catch (e) {
      //   print("Error: $e");
      // }

      // await telephony.requestPhoneAndSmsPermissions;
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
