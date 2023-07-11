import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:sms_encry/constant/constant.dart';

class smsPage extends StatefulWidget {
  final String num;

  const smsPage({required this.num, super.key});

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

  // String decryptAES(String cipherText, String key) {
  //   final keyBytes = encrypt.Key.fromUtf8(key);
  //   final iv = encrypt.IV.fromLength(16);
  //   final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
  //   final decrypted = encrypter.decrypt64(cipherText, iv: iv);
  //   return decrypted;
  // }

  @override
  Widget build(BuildContext context) {
    void _sendSMS(String message, String recipient) async {
      try {
        String _result = await sendSMS(
          message: message,
          recipients: [recipient],
          sendDirect: true,
        );
        print(_result);
        // EasyLoading.showSuccess("SMS sent with encryption");
      } catch (error) {
        print('Failed to send SMS: $error');
        // EasyLoading.showError('$error');
        // Handle the error accordingly
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: widget.num == "" ? Text('UNKNOWN') : Text(widget.num),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                color: Colors.transparent,
                padding: EdgeInsetsDirectional.all(8),
                child: Row(children: [
                  widget.num == ''
                      ? Text(
                          "*you can't send sms without phone number",
                          style: TextStyle(fontSize: 10),
                        )
                      : Expanded(
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
                  widget.num == ''
                      ? Text('')
                      : GestureDetector(
                          onTap: () async {
                            final String originalText = _controller.text;
                            final String encryptionKey = encryptionKey111;
                            String encryptedText =
                                encryptAES(originalText, encryptionKey) +
                                    "encryption";
                            // EasyLoading.showToast(encryptedText);
                            _controller.clear();
                            _sendSMS(encryptedText, widget.num);
                            FocusScope.of(context).unfocus();
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black87,
                            ),
                            child: Icon(
                              Icons.send_outlined,
                              color: Colors.white,
                            ),
                          ),
                        )
                ])),
          ],
        ),
      ),
    );
  }
}
