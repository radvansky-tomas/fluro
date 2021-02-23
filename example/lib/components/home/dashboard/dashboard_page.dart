import 'package:flutter/material.dart';
import 'package:router_example/services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  @override
  State createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('dashboard'),
      child: Center(
        child: FlatButton(
          onPressed: () async {
            await AuthService().logout();
          },
          child: Text('Logout test'),
        ),
      ),
    );
  }
}
