/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'dart:html';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:router_example/components/auth/auth_page.dart';
import 'package:router_example/components/base/base_page.dart';
import 'package:router_example/components/home/contacts/contact_detail_page.dart';
import 'package:router_example/components/home/home_page.dart';
import 'package:router_example/config/application.dart';
import 'package:router_example/services/auth_service.dart';

class Routes {
  static String root = "/";
  static String auth = "/auth";
  static String authLogin = "/auth/login";
  static String authRegister = "/auth/register";
  static String home = "/home";
  static String homeDashboard = "/home/dashboard";
  static String homeContacts = "/home/contacts";
  static String contactDetail = "/home/contacts/:contactId";

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(root,
        handler: rootHandler, transitionType: TransitionType.fadeIn);

    router.define(auth,
        handler: authHandler, transitionType: TransitionType.fadeIn);
    router.define(authLogin,
        handler: authLoginHandler, transitionType: TransitionType.fadeIn);
    router.define(authRegister,
        handler: authRegisterHandler, transitionType: TransitionType.fadeIn);

    router.define(home,
        handler: homeHandler, transitionType: TransitionType.fadeIn);
    router.define(homeDashboard,
        handler: homeDashboardHandler, transitionType: TransitionType.fadeIn);
    router.define(homeContacts,
        handler: homeContactsHandler, transitionType: TransitionType.fadeIn);
    router.define(contactDetail,
        handler: contactDetailHandler,
        transitionType: TransitionType.inFromRight);
  }
}

var rootHandler = Handler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  var currentUser = await AuthService().getCurrentUser();
  if (currentUser != null && currentUser.isNotEmpty) {
    return Redirect(Routes.homeDashboard);
  } else {
    return Redirect(Routes.authLogin);
  }
});

var authHandler = Handler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  return AuthPage(
    isLogin: true,
  );
});

var authLoginHandler = Handler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  return AuthPage(
    isLogin: true,
  );
});

var authRegisterHandler = Handler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  return AuthPage(
    isLogin: false,
  );
});

var homeHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) async{
  return Redirect(Routes.homeDashboard);
});

var homeDashboardHandler = Handler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  return HomePage(
    selectedTab: 0,
  );
});

var homeContactsHandler = Handler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  return HomePage(
    selectedTab: 1,
  );
});

var contactDetailHandler = Handler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  return ContactDetailPage(
    contactId: params['contactId']?.first,
  );
});
