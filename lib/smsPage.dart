import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:sms_encry/constant/constant.dart';

class smsPage extends StatefulWidget {
  const smsPage({super.key});

  @override
  State<smsPage> createState() => _smsPageState();
}

class _smsPageState extends State<smsPage> {
  TextEditingController _controller = TextEditingController();
  String encryptAES(String plainText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String decryptAES(String cipherText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
    final decrypted = encrypter.decrypt64(cipherText, iv: iv);
    return decrypted;
  }

  // List<String> recipients1 = [
  //   '1234567890',
  //   '0987654321'
  // ]; // Sample recipient phone numbers

  // void _sendSMS(String message, List<String> recipents) async {
  //   String _result = await sendSMS(message: message, recipients: recipents)
  //       .catchError((onError) {
  //     print(onError);
  //   });
  //   print(_result);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send encrypted SMS"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                color: Colors.transparent,
                padding: EdgeInsetsDirectional.all(8),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                          labelText: 'Type Your Message...',
                          fillColor: Color(0xFFE4E4E4),
                          filled: true,
                          focusedBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Color(0xFFE4E4E4),
                            ),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none)),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final String originalText = _controller.text;
                      final String encryptionKey = encryptionKey111;
                      String encryptedText =
                          encryptAES(originalText, encryptionKey);
                      EasyLoading.showToast(encryptedText);
                      // _controller.clear();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Icon(
                        Icons.send_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ])),
          ],
        ),
      ),
    );
  }
}