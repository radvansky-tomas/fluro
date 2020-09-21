/*
 * fluro
 * Created by Tomas Radvansky
 * https://www.rdev.software
 * 
 * Copyright (c) 2019 R-DEV, OU. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:router_example/components/home/contacts/contacts_page.dart';
import 'package:router_example/components/home/dashboard/dashboard_page.dart';
import 'package:router_example/config/routes.dart';
import 'package:router_example/services/auth_service.dart';

import '../../config/application.dart';

class HomePage extends StatefulWidget {
  final int selectedTab;

  @override
  State createState() => HomePageState();

  HomePage({this.selectedTab = 0});
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TabController _tabController;
  AuthService _authService;
  int currentIndex;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _tabController = TabController(length: 2, vsync: this);
    currentIndex = widget.selectedTab;
    _tabController.index = currentIndex;
    print('Current Tab:$currentIndex');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (Text(_tabController.index == 0 ? 'Dashboard' : 'Contacts')),
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () async {
            await _authService.logout();
            Application.router.navigateTo(context, Routes.root,
                replace: true, clearStack: true);
          },
        ),
        bottom: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.dashboard)),
            Tab(icon: Icon(Icons.people)),
          ],
          controller: _tabController,
          onTap: (selected) {
            setState(() {
              currentIndex = selected;
            });
            //Update Tab URL
            Future.delayed(Duration.zero, () {
              Application.router.navigateTo(
                context,
                selected == 0 ? Routes.homeDashboard : Routes.homeContacts,
                replace: true,
                clearStack: true,
              );
            });
          },
        ),
      ),
      body: TabBarView(
        children: [DashboardPage(), ContactsPage()],
        controller: _tabController,
      ),
    );
  }

  @override
  void dispose() {
    this._tabController.dispose();
    this._tabController = null;
    super.dispose();
  }
}
