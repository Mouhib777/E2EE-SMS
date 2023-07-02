import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sms_encry/screens/smsPage.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchContacts();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        // If search text is empty, display all contacts
        setState(() {
          _filteredContacts = _contacts;
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
        _filteredContacts = _contacts;
        _isLoading = false;
      });
    } else {
      // Handle permissions not granted
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () async {
            // Kotlin method (Method channel) to set this app as default sms app
            const platform = const MethodChannel("com.example.sms_encry");
            try {
              final result = await platform.invokeMethod('setDefaultSms');
              print("Result1: $result");
            } on PlatformException catch (e) {
              print("Error: $e");
            }
            // end ;
          },
          child: Text("All contacts"),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
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
            )
          : Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(
                    autofocus: false,
                    controller: _searchController,
                    onChanged: (value) {
                      // Filter the contacts based on the search text
                      List<Contact> filteredContacts =
                          _contacts.where((contact) {
                        return contact.displayName
                                ?.toLowerCase()
                                .contains(value.toLowerCase()) ??
                            false;
                      }).toList();

                      setState(() {
                        _filteredContacts = filteredContacts;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      Contact contact = _filteredContacts[index];
                      return ListTile(
                        leading:
                            (contact.avatar == null || contact.avatar!.isEmpty)
                                ? CircleAvatar(
                                    backgroundImage:
                                        AssetImage("assets/images/contact.png"),
                                  )
                                : CircleAvatar(child: Text(contact.initials())),
                        title: Text(
                          contact.displayName ?? '',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          contact.phones!.isNotEmpty
                              ? contact.phones!.first.value ?? ''
                              : '',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        trailing: Icon(CupertinoIcons.chat_bubble),
                        onTap: () {
                          pushNewScreenWithRouteSettings(
                            context,
                            screen: smsPage(
                              num: contact.phones!.isNotEmpty
                                  ? contact.phones!.first.value ?? ''
                                  : '',
                            ),
                            settings: RouteSettings(),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
