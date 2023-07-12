import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:full_expandable_fab/full_expandable_fab.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sms_encry/constant/constant.dart';
import 'package:sms_encry/screens/contactScreen.dart';
import 'package:sms_encry/screens/decryptionPage.dart';
import 'package:sms_encry/screens/smsPage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:encrypt/encrypt.dart' as encrypt;

class AllSms extends StatefulWidget {
  const AllSms({Key? key});

  @override
  State<AllSms> createState() => _AllSmsState();
}

class _AllSmsState extends State<AllSms> {
  String? title;
  String number = "";
  List<Contact> _filteredContacts = [];

  final GlobalKey<ExpandableFabState> keyFab = GlobalKey<ExpandableFabState>();
  Future<List<Map<String, dynamic>>>?
      smsListFuture; // Future for fetching SMS messages
  List<Contact> _contacts = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _smsList = [];

  @override
  void initState() {
    super.initState();
    fetchContacts();
    smsListFuture = fetchSavedSMS();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        // If search text is empty, display all contacts
        setState(() {
          _smsList = [];
        });
      }
    });
  }

  void fetchContacts() async {
    setState(() {
      _isLoading = true;
    });

    if (await Permission.contacts.request().isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();

      setState(() {
        _contacts = contacts.toList();
        _isLoading = false;
      });
    } else {
      // Handle permissions not granted
    }
  }

  @override
  Widget build(BuildContext context) {
    return FullExpandableFab(
      key: keyFab,
      backgroundColor: Colors.white,
      closeIconColor: Colors.black,
      duration: const Duration(milliseconds: 500),
      innerChild: _isLoading
          ? Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Importing all contacts...")
                  ],
                ),
              ),
            )
          : Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        "Recipient:",
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        height: 25,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            number = value;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      IconButton(
                        onPressed: () {
                          pushNewScreenWithRouteSettings(
                            context,
                            screen: smsPage(num: number.toString()),
                            settings: RouteSettings(),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        icon: Icon(
                          Icons.add,
                        ),
                        iconSize: 30,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Or,",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(PageRouteBuilder(
                            transitionDuration: Duration.zero,
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ContactScreen()));
                      },
                      child: Text("Select from my contacts")),
                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width * 0.9,
                  //   height: MediaQuery.of(context).size.height * 0.06,
                  //   child: TextField(
                  //     autofocus: false,
                  //     controller: _searchController,
                  //     onChanged: (value) {
                  //       setState(() {
                  //         _smsList = [];
                  //       });
                  //     },
                  //     decoration: InputDecoration(
                  //       labelText: 'Search',
                  //       prefixIcon: Icon(Icons.search),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(15),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Expanded(
                  //   child: ListView.builder(
                  //     itemCount: _filteredContacts.length,
                  //     itemBuilder: (context, index) {
                  //       Contact contact = _filteredContacts[index];
                  //       return ListTile(
                  //         leading: (contact.avatar == null ||
                  //                 contact.avatar!.isEmpty)
                  //             ? CircleAvatar(
                  //                 backgroundImage:
                  //                     AssetImage("assets/images/contact.png"),
                  //               )
                  //             : CircleAvatar(child: Text(contact.initials())),
                  //         title: Text(
                  //           contact.displayName ?? '',
                  //           style: TextStyle(
                  //               fontSize: 16.0, fontWeight: FontWeight.bold),
                  //         ),
                  //         subtitle: Text(
                  //           contact.phones!.isNotEmpty
                  //               ? contact.phones!.first.value ?? ''
                  //               : '',
                  //           style: TextStyle(fontSize: 14.0),
                  //         ),
                  //         trailing: Icon(CupertinoIcons.chat_bubble),
                  //         onTap: () {
                  //           pushNewScreenWithRouteSettings(
                  //             context,
                  //             screen: smsPage(
                  //               num: contact.phones!.isNotEmpty
                  //                   ? contact.phones!.first.value ?? ''
                  //                   : '',
                  //             ),
                  //             settings: RouteSettings(),
                  //             withNavBar: false,
                  //             pageTransitionAnimation:
                  //                 PageTransitionAnimation.cupertino,
                  //           );
                  //         },
                  //       );
                  //     },
                  //   ),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _smsList.length,
                      itemBuilder: (context, index) {
                        final sender = _smsList[index]['sender'];
                        final messageBody = decryptAES(
                          _smsList[index]['message_body'],
                          encryptionKey111,
                        );

                        return InkWell(
                          onTap: () {
                            pushNewScreenWithRouteSettings(
                              context,
                              screen: decryptionPage(
                                title: sender,
                                body: messageBody,
                              ),
                              settings: RouteSettings(),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: ListTile(
                            title: Text(sender),
                            subtitle: Text(messageBody),
                            trailing: IconButton(
                              onPressed: () {
                                final id = _smsList[index]['id'];
                                if (id != null) {
                                  deleteSMS(id).then((_) {
                                    setState(() {
                                      smsListFuture =
                                          fetchSavedSMS(); // Refresh the SMS messages after deletion
                                    });
                                  });
                                }
                              },
                              icon: Icon(
                                CupertinoIcons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      icon: Icon(
        Icons.add,
        color: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          title: Text(
            "All SMS",
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  smsListFuture = fetchSavedSMS(); // Refresh the SMS messages
                });
              },
              icon: Icon(Icons.refresh),
            ),
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

              // Group SMS messages by sender
              final groupedSmsList = _groupSmsBySender(smsList!);

              return ListView.builder(
                itemCount: groupedSmsList.length,
                itemBuilder: (context, index) {
                  final sender = groupedSmsList[index]['sender'];
                  final messages = groupedSmsList[index]['messages'];

                  return ExpansionTile(
                    subtitle: Text(
                      "${messages.length} SMS",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    title: Text(sender),
                    trailing: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "SMS to $sender",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            content: Text(
                                'To disable ADB, please follow these steps:\n\n'
                                '1. Open the Settings app on your device.\n'
                                '2. Navigate to the Developer Options menu.\n'
                                '3. Disable the "Android Debugging" or "USB Debugging" option.\n'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                            ],
                          ),
                        );
                        // Navigator.of(context).push(PageRouteBuilder(
                        //     transitionDuration: Duration.zero,
                        //     pageBuilder:
                        //         (context, animation, secondaryAnimation) =>
                        //             smsPage(
                        //               num: sender,
                        //             )));
                        Map<String, bool> expansionStateMap = {};
                        // Handle the action when clicking on the right side
                        setState(() {
                          if (expansionStateMap[sender] != null) {
                            expansionStateMap[sender] =
                                !expansionStateMap[sender]!;
                          }
                        });
                      },
                      child: Icon(
                        CupertinoIcons.chat_bubble,
                        color: Colors.black,
                      ),
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...messages.map<Widget>((sms) => ListTile(
                            title: Text(sms['message_body']),
                            trailing: IconButton(
                              onPressed: () {
                                final id = sms['id'];
                                if (id != null) {
                                  deleteSMS(id).then((_) {
                                    setState(() {
                                      smsListFuture = fetchSavedSMS();
                                    });
                                  });
                                }
                              },
                              icon: Icon(
                                CupertinoIcons.delete,
                                color: Colors.red,
                              ),
                            ),
                          )),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupSmsBySender(
      List<Map<String, dynamic>> smsList) {
    final groupedSmsMap = <String, List<Map<String, dynamic>>>{};

    for (final sms in smsList) {
      final sender = sms['sender'];

      if (!groupedSmsMap.containsKey(sender)) {
        groupedSmsMap[sender] = [];
      }

      groupedSmsMap[sender]!.add(sms);
    }

    final groupedSmsList = groupedSmsMap.entries
        .map<Map<String, dynamic>>(
          (entry) => {
            'sender': entry.key,
            'messages': entry.value,
          },
        )
        .toList();

    return groupedSmsList;
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
      // Query the 'sms_table' to fetch the SMS messages sorted by the sender
      final smsList = await database.query(
        'sms_table',
        orderBy: 'sender',
      );

      return smsList;
    } finally {
      await database.close();
    }
  }

  String decryptAES(String cipherText, String key) {
    if (cipherText.isEmpty || key.isEmpty) {
      return ''; // Return an empty string if either cipherText or key is empty
    }

    final keyBytes = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
    final decrypted = encrypter.decrypt64(cipherText, iv: iv);

    return decrypted;
  }

  Future<void> deleteSMS(int id) async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      path.join(databasePath, 'sms_database.db'),
      version: 1, // Specify the database version
    );

    try {
      // Delete the SMS message with the given ID from the 'sms_table'
      await database.delete(
        'sms_table',
        where: 'id = ?',
        whereArgs: [id],
      );
    } finally {
      await database.close();
    }
  }
}
