import 'package:flutter/material.dart';
import 'package:terra/utils/color.dart';

class ContactPage extends StatefulWidget {
  ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final AppColors _colors = AppColors.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messages",
        ),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
