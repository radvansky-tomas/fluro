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
    router.defineAsync(root,
        handler: rootHandler, transitionType: TransitionType.fadeIn);

    router.defineAsync(auth,
        handler: authHandler, transitionType: TransitionType.fadeIn);
    router.defineAsync(authLogin,
        handler: authLoginHandler, transitionType: TransitionType.fadeIn);
    router.defineAsync(authRegister,
        handler: authRegisterHandler, transitionType: TransitionType.fadeIn);

    router.defineAsync(home,
        handler: homeHandler, transitionType: TransitionType.fadeIn);
    router.defineAsync(homeDashboard,
        handler: homeDashboardHandler, transitionType: TransitionType.fadeIn);
    router.defineAsync(homeContacts,
        handler: homeContactsHandler, transitionType: TransitionType.fadeIn);
    router.defineAsync(contactDetail,
        handler: contactDetailHandler,
        transitionType: TransitionType.inFromRight);
  }
}

// Generic Route Guard Function
Future<bool> canActivate() async {
  var currentUser = await AuthService().getCurrentUser();
  await Future.delayed(Duration(seconds: 2));
  return (currentUser != null && currentUser.isNotEmpty);
}

var rootHandler = AsyncHandler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  if (await canActivate()) {
    return Redirect(Routes.homeDashboard);
  } else {
    return Redirect(Routes.authLogin);
  }
});

var authHandler = AsyncHandler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  //Logout first
  await AuthService().logout();
  return Redirect(Routes.authLogin);
});

var authLoginHandler = AsyncHandler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  //Logout first
  await AuthService().logout();
  return AuthPage(
    isLogin: true,
  );
});

var authRegisterHandler = AsyncHandler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  //Logout first
  await AuthService().logout();
  return AuthPage(
    isLogin: false,
  );
});

var homeHandler = AsyncHandler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  if (await canActivate()) {
    return Redirect(Routes.homeDashboard);
  } else {
    return Redirect(Routes.authLogin);
  }
});

var homeDashboardHandler = AsyncHandler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  if (await canActivate()) {
    return HomePage(
      selectedTab: 0,
    );
  } else {
    return Redirect(Routes.authLogin);
  }
});

var homeContactsHandler = AsyncHandler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  if (await canActivate()) {
    return HomePage(
      selectedTab: 1,
    );
  } else {
    return Redirect(Routes.authLogin);
  }
});

var contactDetailHandler = AsyncHandler(handlerFunc:
    (BuildContext context, Map<String, List<String>> params) async {
  if (await canActivate()) {
    return ContactDetailPage(
      contactId: params['contactId']?.first,
    );
  } else {
    return Redirect(Routes.authLogin);
  }
});
