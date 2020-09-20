import 'package:flutter/material.dart';

class ContactDetailPage extends StatefulWidget {
  final String contactId;

  @override
  State createState() => ContactDetailPageState();

  ContactDetailPage({this.contactId});
}

class ContactDetailPageState extends State<ContactDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Contact'),),
        body: Container(
          child: Center(
            child: Text(widget.contactId ?? 'No ID'),
          ),
        ));
  }
}
