import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  State createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('Email'),
          subtitle: TextField(),
        ),
        ListTile(
          title: Text('Password'),
          subtitle: TextField(),
        ),
        ListTile(
          title: RaisedButton(
            child: Text('Register'),
            onPressed: () {},
          ),
        ),
      ],
      shrinkWrap: true,
    );
  }
}
