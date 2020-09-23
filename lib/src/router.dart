/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'package:universal_html/html.dart';

import 'package:fluro/fluro.dart';
import 'package:fluro/src/common.dart';
import 'package:fluro/src/transitions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class FluroRouter {
  static final appRouter = FluroRouter();
  final InitialRouteMatching initialRouteMatching;
  final bool useHash;

  FluroRouter(
      {this.initialRouteMatching = InitialRouteMatching.full,
      this.useHash = true});

  /// The tree structure that stores the defined routes
  final RouteTree _routeTree = RouteTree();

  /// Generic handler for when a route has not been defined
  Handler notFoundHandler;

  /// Internal helper method to return [notFound] page
  Route<Null> _notFoundRoute(BuildContext context, String path) {
    return MaterialPageRoute<Null>(
        settings: RouteSettings(name: path),
        builder: (BuildContext context) {
          return notFoundHandler.handlerFunc(context, null);
        });
  }

  /// Widget being displayed while async routes are processed
  Widget loadingWidget;

  /// In case of loading handler is missing, display simple loading view
  Widget _loadingWidgetFallback = Container(
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );

  /// Internal helper method to return widget defined by [AsyncHandler]
  Widget _futureWidget(BuildContext context, dynamic widgetData) {
    print('_futureWidget - ' + widgetData.toString());
    if (widgetData is Future<Widget>) {
      return FutureBuilder<Widget>(
          future: widgetData,
          builder: (context, AsyncSnapshot<Widget> snapshot) {
            return snapshot.hasData
                ? snapshot.data
                : loadingWidget ?? _loadingWidgetFallback;
          });
    } else if (widgetData is Widget) {
      return widgetData;
    } else {
      return Container(
        child: Center(
          child: Text('Not Found'),
        ),
      );
    }
  }

  /// Creates a [AppRoute] definition for the passed [Handler]. You can optionally provide a default transition type.
  void define(String routePath,
      {@required Handler handler, TransitionType transitionType}) {
    print('Define - ' + routePath);
    _routeTree.addRoute(
      AppRoute(routePath, handler, transitionType: transitionType),
    );
  }

  /// Creates a [AppRoute] definition for the passed [AsyncHandler]. You can optionally provide a default transition type.
  void defineAsync(String routePath,
      {@required AsyncHandler handler, TransitionType transitionType}) {
    print('Define Async - ' + routePath);
    _routeTree.addRoute(
      AppRoute(routePath, handler, transitionType: transitionType),
    );
  }

  AppRoute getAppRoute(
      {BuildContext buildContext, String path, TransitionType transitionType}) {
    print('getAppRoute - ' + path);
    AppRouteMatch match = _routeTree.matchRoute(path);
    AppRoute route = match?.route;
    var handler = (route != null ? route.handler : notFoundHandler);
    var transition = transitionType;
    if (transitionType == null) {
      transition = route != null ? route.transitionType : TransitionType.native;
    }
    var parameters = match?.parameters ?? <String, List<String>>{};
    //return handler.handlerFunc(buildContext, redirectParameters);
    return AppRoute(path, handler,
        transitionType: transition, parameters: parameters);
  }

  /// Logic to process names [path] to [RouteMatch] and add desired parameters such as [routeSettings], [transitionType], [transitionDuration], [transitionsBuilder]
  RouteMatch _matchRoute(BuildContext buildContext, String path,
      {RouteSettings routeSettings,
      TransitionType transitionType,
      Duration transitionDuration = const Duration(milliseconds: 250),
      RouteTransitionsBuilder transitionsBuilder}) {
    print('_matchRoute - ' + path);
    RouteSettings settingsToUse = routeSettings;
    if (routeSettings == null) {
      settingsToUse = RouteSettings(name: path);
    }

    AppRoute appRoute = getAppRoute(
        buildContext: buildContext, path: path, transitionType: transitionType);

    if (appRoute == null && notFoundHandler == null) {
      return RouteMatch(
          matchType: RouteMatchType.noMatch,
          errorMessage: "No matching route was found");
    }

    if (appRoute.handler is Handler || appRoute.handler is AsyncHandler) {
      print('App route is HANDLER');

      /// Process non-visual routes -> functions
      if (appRoute.handler.type == HandlerType.function) {
        print('App route is function');
        appRoute.callHandler(buildContext);
        return RouteMatch(matchType: RouteMatchType.nonVisual);
      }

      var handlerFunc = appRoute.callHandler(buildContext);
      if (handlerFunc is Redirect) {
        print('handlerFunc is Redirect');

        /// Recursive function
        return _matchRoute(buildContext, handlerFunc.route,
            routeSettings: RouteSettings(name: handlerFunc.route),
            transitionType: appRoute.transitionType,
            transitionDuration: transitionDuration,
            transitionsBuilder: transitionsBuilder);
      } else if (handlerFunc is Future<Redirect>) {
        print('handlerFunc is Future Redirect' + handlerFunc.toString());
        return RouteMatch(
          matchType: RouteMatchType.redirect,
          route: WebMaterialPageRoute<dynamic>(
              //TODO: This needs to update async, that's why using [window.history.pushState]
              settings: settingsToUse,
              builder: (BuildContext context) {
                print('WebMaterialPageRoute Builder');
                return FutureBuilder<Redirect>(
                  future: handlerFunc,
                  builder: (context, snapshot) {
                    print('WebMaterialPageRoute Future Builder');
                    if (snapshot.hasData) {
                      window.history.pushState(null, snapshot.data.route,
                          (this.useHash ? '#' : '') + snapshot.data.route);
                      var newMatch = _matchRoute(context, snapshot.data.route,
                          routeSettings: settingsToUse,
                          transitionType: appRoute.transitionType,
                          transitionDuration: transitionDuration,
                          transitionsBuilder: transitionsBuilder);
                      //TODO check how to execute animations here
                      return newMatch.route.buildPage(context, null, null);
                    }
                    return loadingWidget ?? _loadingWidgetFallback;
                  },
                );
              }),
        );
      } else if (handlerFunc is Widget || handlerFunc is Future<Widget>) {
        print('handlerFunc is Widget or Future');
        PageRoute createdRoute = _createPageRoute(appRoute, settingsToUse,
            handlerFunc, transitionDuration, transitionsBuilder);

        return RouteMatch(
          matchType: RouteMatchType.visual,
          route: createdRoute,
        );
      }
    }

    print('No matching route was found');
    return RouteMatch(
        matchType: RouteMatchType.noMatch,
        errorMessage: "No matching route was found");
  }

  Route<dynamic> _createPageRoute(
      AppRoute route,
      RouteSettings routeSettings,
      dynamic handlerFunc,
      Duration transitionDuration,
      RouteTransitionsBuilder transitionsBuilder) {
    print(_createPageRoute);
    print(handlerFunc);
    bool isNativeTransition = (route.transitionType == TransitionType.native ||
        route.transitionType == TransitionType.nativeModal);
    if (isNativeTransition && !UniversalPlatform.isWeb) {
      if (UniversalPlatform.isIOS) {
        return CupertinoPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog:
                route.transitionType == TransitionType.nativeModal,
            builder: (BuildContext context) {
              return _futureWidget(context, handlerFunc);
            });
      } else {
        return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog:
                route.transitionType == TransitionType.nativeModal,
            builder: (BuildContext context) {
              return _futureWidget(context, handlerFunc);
            });
      }
    } else if (route.transitionType == TransitionType.material ||
        route.transitionType == TransitionType.materialFullScreenDialog) {
      return MaterialPageRoute<dynamic>(
          settings: routeSettings,
          fullscreenDialog:
              route.transitionType == TransitionType.materialFullScreenDialog,
          builder: (BuildContext context) {
            return _futureWidget(context, handlerFunc);
          });
    } else if (route.transitionType == TransitionType.cupertino ||
        route.transitionType == TransitionType.cupertinoFullScreenDialog) {
      return CupertinoPageRoute<dynamic>(
          settings: routeSettings,
          fullscreenDialog:
              route.transitionType == TransitionType.cupertinoFullScreenDialog,
          builder: (BuildContext context) {
            return _futureWidget(context, handlerFunc);
          });
    } else {
      var routeTransitionsBuilder;
      if (route.transitionType == TransitionType.custom) {
        routeTransitionsBuilder = transitionsBuilder;
      } else {
        routeTransitionsBuilder =
            FluroTransitions.buildTransitions(route.transitionType);
      }
      if (UniversalPlatform.isWeb) {
        return WebMaterialPageRoute<dynamic>(
            settings: routeSettings,
            transitionDuration: transitionDuration,
            transitionsBuilder: routeTransitionsBuilder,
            fullscreenDialog:
                route.transitionType == TransitionType.materialFullScreenDialog,
            builder: (BuildContext context) {
              return _futureWidget(context, handlerFunc);
            });
      } else {
        return PageRouteBuilder<dynamic>(
          settings: routeSettings,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return _futureWidget(context, handlerFunc);
          },
          transitionDuration: transitionDuration,
          transitionsBuilder: routeTransitionsBuilder,
        );
      }
    }
  }

  /// Route generation method. This function can be used as a way to create routes on-the-fly
  /// if any defined handler is found. It can also be used with the [MaterialApp.onGenerateRoute]
  /// property as callback to create routes that can be used with the [Navigator] class.
  Route<dynamic> generator(RouteSettings routeSettings) {
    print('generator');
    RouteMatch match =
        _matchRoute(null, routeSettings.name, routeSettings: routeSettings);
    return match.route;
  }

  /// InitialRoute Generator method. This function can be used as a way to create initial routes on
  /// hard page refresh or deep links. Its dependant on [requiredInitialRouteMatching] which is by default
  /// set to [InitialRouteMatching.full]. In that case full PATH needs to match to return just its result.
  /// Otherwise [path] is parsed into multiple segments divided by '/' to provide partial routes as history.
  List<Route<dynamic>> initialGenerator(String path) {
    RouteMatch rootMatch = _matchRoute(null, '/', routeSettings: null);
    print('inital generator');
    if (this.initialRouteMatching == InitialRouteMatching.full) {
      RouteMatch fullMatch = _matchRoute(null, path, routeSettings: null);
      print('FullMatch');
      print(fullMatch);

      /// Returns full match if its [RouteMatchType.visual] or [RouteMatchType.redirect] otherwise [rootMatch]
      return fullMatch.route != null &&
                  fullMatch.matchType == RouteMatchType.visual ||
              fullMatch.matchType == RouteMatchType.redirect
          ? [fullMatch.route]
          : [rootMatch.route];
    } else {
      /// Requires full processing of partial matches, do not include empty routes
      var segments =
          path.split('/').where((element) => element.isNotEmpty).toList();

      List<Route<dynamic>> result = [];

      if (segments != null && segments.length > 0) {
        for (int i = 0; i < segments.length + 1; i++) {
          /// Now reconstruct paths from start
          var joined = '/' + segments.sublist(0, i).join('/');
          var matched = _matchRoute(null, joined.isEmpty ? '/' : joined);
          if (matched.matchType != RouteMatchType.redirect) {
            result.add(matched.route);
            print('Adding:' + joined);
          } else {
            print('Not adding:' + joined);
          }
        }
      }

      if (result.length > 0) {
        print('Returning Initial result');
        print(result);
        return result;
      } else {
        /// Requires partial match, but nothing found -> [rootMatch]
        print('Returning rootMatch');
        return [rootMatch.route];
      }
    }
  }

  /// Helper function to return [result] from pop() method
  pop<T extends Object>(BuildContext context, [T result]) =>
      Navigator.pop(context, result);

  /// Use this method instead of generic [Navigator.push]
  Future navigateTo(BuildContext context, String path,
      {bool replace = false,
      bool clearStack = false,
      TransitionType transition,
      Duration transitionDuration = const Duration(milliseconds: 250),
      RouteTransitionsBuilder transitionBuilder}) {
    RouteMatch routeMatch = _matchRoute(context, path,
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

  /// Finds a defined [AppRoute] for the path value. If no [AppRoute] definition was found
  /// then function will return null.
  AppRouteMatch match(String path) {
    return _routeTree.matchRoute(path);
  }

  /// DEBUG method which prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}
