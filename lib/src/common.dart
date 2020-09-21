/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
enum HandlerType {
  route,
  function,
}

///
class Handler {
  Handler({this.type = HandlerType.route, this.handlerFunc});

  final HandlerType type;
  final HandlerFunc handlerFunc;
}

///
class Redirect {
  final String route;
  Redirect(this.route);
}

///
typedef Route<T> RouteCreator<T>(
    RouteSettings route, Map<String, List<String>> parameters);

///
typedef Future<dynamic> HandlerFunc(
    BuildContext context, Map<String, List<String>> parameters);

///
class AppRoute {
  String route;
  Handler handler;
  TransitionType transitionType;

  AppRoute(this.route, this.handler, {this.transitionType});
}

enum TransitionType {
  native,
  nativeModal,
  inFromLeft,
  inFromRight,
  inFromTop,
  inFromBottom,
  fadeIn,
  custom, // if using custom then you must also provide a transition
  material,
  materialFullScreenDialog,
  cupertino,
  cupertinoFullScreenDialog,
}

enum RouteMatchType {
  visual,
  nonVisual,
  noMatch,
  redirect
}

///
class RouteMatch {
  RouteMatch(
      {this.matchType = RouteMatchType.noMatch,
      this.route,
      this.errorMessage = "Unable to match route. Please check the logs."});

  final Route<dynamic> route;
  RouteMatchType matchType;
  final String errorMessage;
}

class RouteNotFoundException implements Exception {
  final String message;
  final String path;

  RouteNotFoundException(this.message, this.path);

  @override
  String toString() {
    return "No registered route was found to handle '$path'";
  }
}

class WebMaterialPageRoute<T> extends MaterialPageRoute<T> {
  final Duration transitionDuration;
  final RouteTransitionsBuilder transitionsBuilder;
  WebMaterialPageRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    this.transitionDuration = const Duration(milliseconds: 250),
    this.transitionsBuilder
  }) : super(
      builder: builder,
      maintainState: maintainState,
      settings: settings,
      fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return transitionsBuilder(context,animation,secondaryAnimation,child) ?? child;
  }
}
