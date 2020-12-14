import 'package:flutter/material.dart';
import 'package:router_example/config/application.dart';
import 'package:router_example/config/routes.dart';
import 'package:router_example/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('Email'),
          subtitle: TextField(),
          key: ValueKey('email'),
        ),
        ListTile(
          title: Text('Password'),
          key: ValueKey('password'),
          subtitle: TextField(),
        ),
        ListTile(
          title: RaisedButton(
            child: Text('Login'),
            key: ValueKey('login'),
            onPressed: () async {
              await _authService.login('email', 'password');
              Application.router.navigateTo(context, Routes.root,replace: true, clearStack: true);
            },
          ),
        ),
      ],
      shrinkWrap: true,
    );
  }
}
