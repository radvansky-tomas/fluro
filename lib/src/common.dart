/*
 * fluro2
 * Created by R-Dev
 * Tomas Radvansky
 *
 * Inspired by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2020 R-Dev, OU. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:fluro/src/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// [route] is [visual] representation, ie [Widget] whilst
///
/// [function] is [nonVisual] representation, calling method
enum HandlerType {
  route,
  function,
}

/// [full] matching returns ONLY one segment defined exactly,
///
/// while [partial] returns EVERY segment of route.
enum InitialRouteMatching {
  full,
  partial,
}

/// [visual] - widget representation
///
/// [nonVisual] - [function] representation
///
/// [noMatch] - route not found
///
/// [redirect] - redirection to another [visual] route
enum RouteMatchType { visual, nonVisual, noMatch, redirect }

/// Defines [type] - [route] or [function] and [handlerFunc]
///
/// to execute it asynchronously
class AsyncHandler {
  AsyncHandler({this.type = HandlerType.route, required this.handlerFunc});

  final HandlerType type;
  final AsyncHandlerFunc handlerFunc;
}

/// Defines [type] - [route] or [function] and [handlerFunc]
///
/// to execute it
class Handler {
  Handler({this.type = HandlerType.route, required this.handlerFunc});

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
    BuildContext context, Map<String, List<String>>? parameters);

///
class AppRoute {
  AppRoute(this.route, this.handler, {this.transitionType, this.parameters});

  final String? route;

  /// Can be [Handler] or [AsyncHandler]
  final dynamic handler;
  final TransitionType? transitionType;
  final Map<String, List<String>>? parameters;

  dynamic callHandler(BuildContext? context) {
    print(handler);
    if (handler is Handler) {
      return handler.handlerFunc(context, parameters);
    } else if (handler is AsyncHandler) {
      return handler.handlerFunc(context, parameters);
    }
  }
}

/// Is passed to native [Navigator], is contains abstract [route]
///
/// with parsed [matchType], unless [Error] occurred [errorMessage]
class RouteMatch {
  RouteMatch(
      {this.matchType = RouteMatchType.noMatch,
      this.route,
      this.errorMessage = "Unable to match route. Please check the logs."});

  final PageRoute? route;
  RouteMatchType matchType;
  final String errorMessage;
}

/// Custom [Exception] thrown as 404 error with [message] and [path]
class RouteNotFoundException implements Exception {
  final String message;
  final String path;

  RouteNotFoundException(this.message, this.path);

  @override
  String toString() {
    return "No registered route was found to handle '$path'";
  }
}

/// Adds support for WEB based transitions. Extends [MaterialPageRoute]
///
/// and keeps navigation, stack in order.
class WebMaterialPageRoute<T> extends MaterialPageRoute<T> {
  final Duration transitionDuration;
  final RouteTransitionsBuilder? transitionsBuilder;

  WebMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 250),
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return transitionsBuilder != null
        ? transitionsBuilder!(context, animation, secondaryAnimation, child)
        : child;
  }
}
