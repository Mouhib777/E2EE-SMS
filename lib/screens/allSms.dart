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
  Future<List<Map<String, dynamic>>>?
      smsListFuture; // Future for fetching SMS messages

  @override
  void initState() {
    super.initState();
    // Fetch SMS messages when the page is initialized
    smsListFuture = fetchSavedSMS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text("All SMS"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  smsListFuture = fetchSavedSMS(); // Refresh the SMS messages
                });
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: smsListFuture, // Use the Future for fetching SMS messages
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching the SMS messages
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if there was an error fetching the SMS messages
            return Center(child: Text('Error: ${snapshot.error}'));
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
                      trailing: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            CupertinoIcons.delete,
                            color: Colors.red,
                          ))),
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
      version: 1, // Specify the database version
      onCreate: (db, version) {
        // Create the 'sms_table' if it doesn't exist
        db.execute('CREATE TABLE IF NOT EXISTS sms_table '
            '(id INTEGER PRIMARY KEY, sender TEXT, message_body TEXT)');
      },
    );

    try {
      // Query the 'sms_table' to fetch the SMS messages
      final smsList = await database.query('sms_table');
      return smsList;
    } finally {
      await database.close();
    }
  }

  String decryptAES(String cipherText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
    final decrypted = encrypter.decrypt64(cipherText, iv: iv);
    return decrypted;
  }
}
