/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:fluro/src/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class FluroRouter {
  static final appRouter = FluroRouter();
  final RouteMatchType requiredInitialMatchType;

  FluroRouter({this.requiredInitialMatchType = RouteMatchType.visual});

  /// The tree structure that stores the defined routes
  final RouteTree _routeTree = RouteTree();

  /// Generic handler for when a route has not been defined
  Handler notFoundHandler;

  /// Creates a [PageRoute] definition for the passed [RouteHandler]. You can optionally provide a default transition type.
  void define(String routePath,
      {@required Handler handler, TransitionType transitionType}) {
    _routeTree.addRoute(
      AppRoute(routePath, handler, transitionType: transitionType),
    );
  }

  /// Finds a defined [AppRoute] for the path value. If no [AppRoute] definition was found
  /// then function will return null.
  AppRouteMatch match(String path) {
    return _routeTree.matchRoute(path);
  }

  pop<T extends Object>(BuildContext context, [T result]) =>
      Navigator.pop(context, result);

  ///
  Future navigateTo(BuildContext context, String path,
      {bool replace = false,
      bool clearStack = false,
      TransitionType transition,
      Duration transitionDuration = const Duration(milliseconds: 250),
      RouteTransitionsBuilder transitionBuilder}) {
    RouteMatch routeMatch = matchRoute(context, path,
        transitionType: transition,
        transitionsBuilder: transitionBuilder,
        transitionDuration: transitionDuration);
    Route<dynamic> route = routeMatch.route;
    Completer completer = Completer();
    Future future = completer.future;
    if (routeMatch.matchType == RouteMatchType.nonVisual) {
      completer.complete("Non visual route type.");
    } else {
      if (route == null && notFoundHandler != null) {
        route = _notFoundRoute(context, path);
      }
      if (route != null) {
        if (clearStack) {
          future =
              Navigator.pushAndRemoveUntil(context, route, (check) => false);
        } else {
          future = replace
              ? Navigator.pushReplacement(context, route)
              : Navigator.push(context, route);
        }
        completer.complete();
      } else {
        String error = "No registered route was found to handle '$path'.";
        print(error);
        completer.completeError(RouteNotFoundException(error, path));
      }
    }

    return future;
  }

  ///
  Route<Null> _notFoundRoute(BuildContext context, String path) {
    RouteCreator<Null> creator =
        (RouteSettings routeSettings, Map<String, List<String>> parameters) {
      return MaterialPageRoute<Null>(
          settings: routeSettings,
          builder: (BuildContext context) {
            return futureWidget(
                context, notFoundHandler.handlerFunc(context, parameters));
          });
    };
    return creator(RouteSettings(name: path), null);
  }

  Widget futureWidget(BuildContext context, Future<Widget> data) {
    return FutureBuilder<Widget>(
        future: data,
        builder: (context, AsyncSnapshot<Widget> snapshot) {
          return snapshot.hasData
              ? snapshot.data
              : Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
        });
  }


  ///
  RouteMatch matchRoute(BuildContext buildContext, String path,
      {RouteSettings routeSettings,
      TransitionType transitionType,
      Duration transitionDuration = const Duration(milliseconds: 250),
      RouteTransitionsBuilder transitionsBuilder}) {
    RouteSettings settingsToUse = routeSettings;
    if (routeSettings == null) {
      settingsToUse = RouteSettings(name: path);
    }
    AppRouteMatch match = _routeTree.matchRoute(path);
    AppRoute route = match?.route;
    Handler handler = (route != null ? route.handler : notFoundHandler);
    var transition = transitionType;
    if (transitionType == null) {
      transition = route != null ? route.transitionType : TransitionType.native;
    }
    if (route == null && notFoundHandler == null) {
      return RouteMatch(
          matchType: RouteMatchType.noMatch,
          errorMessage: "No matching route was found");
    }
    Map<String, List<String>> parameters =
        match?.parameters ?? <String, List<String>>{};
    if (handler.type == HandlerType.function) {
      handler.handlerFunc(buildContext, parameters);
      return RouteMatch(matchType: RouteMatchType.nonVisual);
    }

    var handlerFunc = handler.handlerFunc(buildContext, parameters);
    if (handlerFunc is Future<Redirect>) {
      var routeTransitionsBuilder;
      if (transition == TransitionType.custom) {
        routeTransitionsBuilder = transitionsBuilder;
      } else {
        routeTransitionsBuilder = _standardTransitionsBuilder(transition);
      }
      return RouteMatch(
        matchType: RouteMatchType.redirect,
        route: WebMaterialPageRoute<dynamic>(
            settings: routeSettings,
            transitionDuration: transitionDuration,
            transitionsBuilder: routeTransitionsBuilder,
            fullscreenDialog:
                transition == TransitionType.materialFullScreenDialog,
            builder: (BuildContext context) {
              return FutureBuilder<Redirect>(
                  future: handlerFunc,
                  builder: (context, AsyncSnapshot<Redirect> snapshot) {
                    if (snapshot.hasData) {
                      AppRouteMatch redirectMatch =
                          _routeTree.matchRoute(snapshot.data.route);
                      AppRoute redirectRoute = redirectMatch?.route;
                      Handler redirectHandler = (redirectRoute != null
                          ? redirectRoute.handler
                          : notFoundHandler);
                      var redirectHandlerFunc =
                          redirectHandler.handlerFunc(buildContext, parameters);

                      if (redirectHandlerFunc is Future<Widget>) {
                        return futureWidget(context, redirectHandlerFunc);
                      } else {
                        return Container(
                            child: Center(
                          child: CircularProgressIndicator(),
                        ));
                      }
                    } else {
                      return Container(
                          child: Center(
                        child: CircularProgressIndicator(),
                      ));
                    }
                  });
            }),
      );
    } else if (handlerFunc is Future<Widget>) {
      PageRoute createdRoute = createRoute(settingsToUse, parameters,
          handlerFunc, transition, transitionDuration, transitionsBuilder);

      return RouteMatch(
        matchType: RouteMatchType.visual,
        route: createdRoute,
      );
    }
    return RouteMatch(
        matchType: RouteMatchType.noMatch,
        errorMessage: "No matching route was found");
  }

  Route<dynamic> createRoute(
      RouteSettings routeSettings,
      Map<String, List<String>> parameters,
      Future<Widget> handlerFunc,
      TransitionType transition,
      Duration transitionDuration,
      RouteTransitionsBuilder transitionsBuilder) {
    bool isNativeTransition = (transition == TransitionType.native ||
        transition == TransitionType.nativeModal);
    if (isNativeTransition && !UniversalPlatform.isWeb) {
      if (UniversalPlatform.isIOS) {
        return CupertinoPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: transition == TransitionType.nativeModal,
            builder: (BuildContext context) {
              return futureWidget(context, handlerFunc);
            });
      } else {
        return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: transition == TransitionType.nativeModal,
            builder: (BuildContext context) {
              return futureWidget(context, handlerFunc);
            });
      }
    } else if (transition == TransitionType.material ||
        transition == TransitionType.materialFullScreenDialog) {
      return MaterialPageRoute<dynamic>(
          settings: routeSettings,
          fullscreenDialog:
              transition == TransitionType.materialFullScreenDialog,
          builder: (BuildContext context) {
            return futureWidget(context, handlerFunc);
          });
    } else if (transition == TransitionType.cupertino ||
        transition == TransitionType.cupertinoFullScreenDialog) {
      return CupertinoPageRoute<dynamic>(
          settings: routeSettings,
          fullscreenDialog:
              transition == TransitionType.cupertinoFullScreenDialog,
          builder: (BuildContext context) {
            return futureWidget(context, handlerFunc);
          });
    } else {
      var routeTransitionsBuilder;
      if (transition == TransitionType.custom) {
        routeTransitionsBuilder = transitionsBuilder;
      } else {
        routeTransitionsBuilder = _standardTransitionsBuilder(transition);
      }
      if (UniversalPlatform.isWeb) {
        return WebMaterialPageRoute<dynamic>(
            settings: routeSettings,
            transitionDuration: transitionDuration,
            transitionsBuilder: routeTransitionsBuilder,
            fullscreenDialog:
                transition == TransitionType.materialFullScreenDialog,
            builder: (BuildContext context) {
              return futureWidget(context, handlerFunc);
            });
      } else {
        return PageRouteBuilder<dynamic>(
          settings: routeSettings,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return futureWidget(context, handlerFunc);
          },
          transitionDuration: transitionDuration,
          transitionsBuilder: routeTransitionsBuilder,
        );
      }
    }
  }

  RouteTransitionsBuilder _standardTransitionsBuilder(
      TransitionType transitionType) {
    return (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      if (transitionType == TransitionType.fadeIn) {
        return FadeTransition(opacity: animation, child: child);
      } else {
        const Offset topLeft = const Offset(0.0, 0.0);
        const Offset topRight = const Offset(1.0, 0.0);
        const Offset bottomLeft = const Offset(0.0, 1.0);
        Offset startOffset = bottomLeft;
        Offset endOffset = topLeft;
        if (transitionType == TransitionType.inFromLeft) {
          startOffset = const Offset(-1.0, 0.0);
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromRight) {
          startOffset = topRight;
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromTop) {
          startOffset = const Offset(0.0, -1.0);
          endOffset = const Offset(0.0, 1.0);
        }

        return SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      }
    };
  }

  /// Route generation method. This function can be used as a way to create routes on-the-fly
  /// if any defined handler is found. It can also be used with the [MaterialApp.onGenerateRoute]
  /// property as callback to create routes that can be used with the [Navigator] class.
  Route<dynamic> generator(RouteSettings routeSettings) {
    RouteMatch match =
        matchRoute(null, routeSettings.name, routeSettings: routeSettings);
    return match.route;
  }

  /// InitialRoute Generator method. This function can be used as a way to create initial routes on
  /// hard page refresh or deep links. Its dependant on [requiredInitialMatchType] which is by default
  /// set to [RouteMatchType.visual]. In that case full PATH needs to match to return just its result.
  /// Otherwise [path] is parsed into multiple segments divided by '/' to provide partial routes as history.
  List<Route<dynamic>> initialGenerator(String path) {
    RouteMatch rootMatch = matchRoute(null, '/', routeSettings: null);
    if (this.requiredInitialMatchType == RouteMatchType.visual) {
      //Requires full match but not found, redirect to initial page
      return [rootMatch.route];
    } else {
      //Requires full processing
      var segments =
          path.split('/').where((element) => element.isNotEmpty).toList();
      print(
          'Segments(' + segments.length.toString() + '):' + segments.join(','));
      List<Route<dynamic>> result = [];
      if (segments != null && segments.length > 0) {
        for (int i = 0; i < segments.length + 1; i++) {
          var joined = '/' + segments.sublist(0, i).join('/');
          var matched = matchRoute(null, joined.isEmpty ? '/' : joined);
          if (matched.matchType != RouteMatchType.redirect) {
            result.add(matched.route);
            print('Adding:' + joined);
          } else {
            print('Not adding:' + joined);
          }
        }
      }
      if (result.length > 0) {
        return result;
      } else {
        //Requires full processing but not found, redirect to initial page
        return [rootMatch.route];
      }
    }
  }

  /// Prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}
