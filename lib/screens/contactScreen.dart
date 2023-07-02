import 'package:flutter/material.dart';

class contactSCreen extends StatefulWidget {
  const contactSCreen({super.key});

  @override
  State<contactSCreen> createState() => _contactSCreenState();
}

class _contactSCreenState extends State<contactSCreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All contacts"),
        centerTitle: true,
      ),
    );
  }
}
