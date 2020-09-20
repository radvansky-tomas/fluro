import 'package:flutter/material.dart';
import 'package:router_example/config/application.dart';
import 'package:router_example/config/routes.dart';

class ContactsPage extends StatefulWidget {
  @override
  State createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: Text('John Smith'),
          subtitle: Text('id: abc123'),
          onTap: () {
            Application.router
                .navigateTo(context, Routes.homeContacts + '/abc123');
          },
        ),
        ListTile(
          title: Text('Alan Smith'),
          subtitle: Text('id: 421vsf'),
          onTap: () {
            Application.router
                .navigateTo(context, Routes.homeContacts + '/421vsf');
          },
        )
      ],
    );
  }
}
