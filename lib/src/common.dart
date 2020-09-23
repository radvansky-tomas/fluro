/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:fluro/src/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///Enums

///
enum HandlerType {
  route,
  function,
}

///
enum InitialRouteMatching {
  full,
  partial,
}

enum RouteMatchType { visual, nonVisual, noMatch, redirect }

///
class AsyncHandler {
  AsyncHandler({this.type = HandlerType.route, this.handlerFunc});

  final HandlerType type;
  final AsyncHandlerFunc handlerFunc;
}

class Handler {
  Handler({this.type = HandlerType.route, this.handlerFunc});

  final HandlerType type;
  final HandlerFunc handlerFunc;
}

/// Desired [route] to redirect
class Redirect {
  Redirect(this.route);

  final String route;
}

///
typedef Route<T> RouteCreator<T>(
    RouteSettings route, Map<String, List<String>> parameters);

/// Returns dynamic [Future] which contains either [Widget] or [Redirect]
typedef Future<dynamic> AsyncHandlerFunc(
    BuildContext context, Map<String, List<String>> parameters);

/// Returns either [Widget] or [Redirect]
typedef dynamic HandlerFunc(
    BuildContext context, Map<String, List<String>> parameters);

///
class AppRoute {
  AppRoute(this.route, this.handler, {this.transitionType, this.parameters});

  final String route;

  /// Can be [Handler] or [AsyncHandler]
  final dynamic handler;
  final TransitionType transitionType;
  final Map<String, List<String>> parameters;

  dynamic callHandler(BuildContext context) {
    print(handler);
    if (handler is Handler) {
      return handler.handlerFunc(context, parameters);
    } else if (handler is AsyncHandler) {
      return handler.handlerFunc(context, parameters);
    }
  }
}

///
class RouteMatch {
  RouteMatch(
      {this.matchType = RouteMatchType.noMatch,
      this.route,
      this.errorMessage = "Unable to match route. Please check the logs."});

  final PageRoute route;
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
    this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 250),
    //this.transitionsBuilder
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return transitionsBuilder != null
        ? transitionsBuilder(context, animation, secondaryAnimation, child) ??
            child
        : child;
  }
}
