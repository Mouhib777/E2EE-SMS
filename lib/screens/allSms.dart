import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sms_encry/constant/constant.dart';
import 'package:sms_encry/screens/decryptionPage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:async';

class AllSms extends StatefulWidget {
  const AllSms({Key? key});

  @override
  State<AllSms> createState() => _AllSmsState();
}

class _AllSmsState extends State<AllSms> {
  String decryptAES(String cipherText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
    final decrypted = encrypter.decrypt64(cipherText, iv: iv);
    return decrypted;
  }

  Timer? timer; // Timer object to reload the page

  @override
  void initState() {
    super.initState();
    // Start the timer when the page is initialized
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the timer when the page is disposed
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All SMS"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSavedSMS(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching the SMS messages
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Show an error message if there was an error fetching the SMS messages
            return Text('Error: ${snapshot.error}');
          } else {
            // Display the SMS messages
            final smsList = snapshot.data;

            return ListView.builder(
              itemCount: smsList!.length,
              itemBuilder: (context, index) {
                final sender = smsList[index]['sender'];
                final messageBody = decryptAES(
                    smsList[index]['message_body'], encryptionKey111);

                return InkWell(
                  onTap: () {
                    pushNewScreenWithRouteSettings(context,
                        screen: decryptionPage(
                          title: sender,
                          body: messageBody,
                        ),
                        settings: RouteSettings(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino);
                  },
                  child: ListTile(
                    title: Text(sender),
                    subtitle: Text(messageBody),
                    trailing: Icon(CupertinoIcons.chat_bubble),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchSavedSMS() async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      path.join(databasePath, 'sms_database.db'),
    );

    // Check if the 'sms_table' exists in the database
    final tables = await database.query("sqlite_master",
        where: "type = 'table' AND name = 'sms_table'");
    if (tables.isEmpty) {
      await database.close();
      return []; // Return an empty list when the table doesn't exist
    }

    // Query the 'sms_table' only when it exists
    final smsList = await database.query('sms_table');
    await database.close();

    if (smsList.isEmpty) {
      return [
        {'sender': 'No SMS found', 'message_body': 'No SMS found'}
      ]; // Return a single entry when no SMS messages are found in the table
    }

    return smsList;
  }
}
