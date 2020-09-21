import 'package:flutter/material.dart';
import 'package:router_example/config/application.dart';
import 'package:router_example/config/routes.dart';
import 'package:router_example/services/auth_service.dart';

class BasePage extends StatefulWidget {
  @override
  State createState() => BasePageState();
}

class BasePageState extends State<BasePage> {
  AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    // _authService.getCurrentUser().then((value) {
    //   if (value != null && value.isNotEmpty) {
    //     Application.router
    //         .navigateTo(context, Routes.home, clearStack: true, replace: true);
    //   } else {
    //     Application.router.navigateTo(context, Routes.authLogin,
    //         clearStack: true, replace: true);
    //   }
    // }).catchError(() {
    //   Application.router.navigateTo(context, Routes.authLogin,
    //       clearStack: true, replace: true);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
