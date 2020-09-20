import 'package:flutter/material.dart';
import 'package:router_example/components/auth/login/login_page.dart';
import 'package:router_example/components/auth/register/register_page.dart';

class AuthPage extends StatefulWidget {
  final bool isLogin;

  @override
  State createState() => AuthPageState();

  AuthPage({this.isLogin = true});
}

class AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.isLogin ? LoginPage() : RegisterPage(),
      ),
    );
  }
}
