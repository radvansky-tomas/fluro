import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  @override
  State createState() => BasePageState();
}

class BasePageState extends State<BasePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('loading'),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
