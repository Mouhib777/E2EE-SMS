import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sms_encry/constant/constant.dart';
import 'package:sms_encry/screens/smsPage.dart';

class decryptionPage extends StatefulWidget {
  final String title;
  final String body;
  const decryptionPage({required this.title, required this.body, super.key});

  @override
  State<decryptionPage> createState() => _decryptionPageState();
}

class _decryptionPageState extends State<decryptionPage> {
  String decryptAES(String cipherText, String key) {
    if (cipherText.isEmpty || key.isEmpty) {
      return ""; // Return an empty string if either cipherText or key is empty
    }

    final keyBytes = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
    final decrypted = encrypter.decrypt64(cipherText, iv: iv);

    return decrypted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                pushNewScreenWithRouteSettings(context,
                    screen: smsPage(
                      num: widget.title,
                    ),
                    settings: RouteSettings(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino);
              },
              icon: Icon(CupertinoIcons.chat_bubble))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.body),
                  )),
            ),
            SizedBox(
              height: 30,
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //       decoration: BoxDecoration(
            //           border: Border.all(color: Colors.black),
            //           borderRadius: BorderRadius.circular(15)),
            //       child: Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Text(
            //           widget.body,
            //         ),
            //       )),
            // ),
          ],
        ),
      ),
    );
  }
}
