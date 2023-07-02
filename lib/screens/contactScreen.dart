import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchContacts();
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All contacts"),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                Contact contact = _contacts[index];
                return ListTile(
                  leading: (contact.avatar == null && contact.avatar!.isEmpty)
                      ? CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/images/contact.png"),
                        )
                      : CircleAvatar(child: Text(contact.initials())),
                  title: Text(
                    contact.displayName ?? '',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    contact.phones!.isNotEmpty
                        ? contact.phones!.first.value ?? ''
                        : '',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  trailing: Icon(CupertinoIcons.chat_bubble),
                  // Image.asset(
                  //   "assets/images/messaging.png",
                  //   width: 30,
                  // ),
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
    );
  }
}
