// Imports the Flutter Driver API.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// The application under test.
import 'package:router_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    setUpAll(() async {});

    testWidgets('Should START with loading screen', (WidgetTester tester) async {
      await tester.runAsync(() async {
        //Finders
        var loadingFinder = find.byType(CircularProgressIndicator);
        //Init app
        app.main();
        await tester.pump();
        //Get Base page
        await Future.delayed(Duration(seconds: 2));
        await tester.pump();
        expect(loadingFinder, findsOneWidget);
      });
    });

    testWidgets('Should PRESENT login page', (WidgetTester tester) async {
      await tester.runAsync(() async {
        //Finders
        var loadingFinder = find.byType(CircularProgressIndicator);
        var emailFinder = find.byKey(ValueKey('email'));
        var passwordFinder = find.byKey(ValueKey('password'));
        var loginFinder = find.byKey(ValueKey('login'));
        //Init app
        app.main();
        await tester.pump();
        //Get Base page
        await Future.delayed(Duration(seconds: 2));
        await tester.pump();
        expect(loadingFinder, findsOneWidget);
        //Should go to loading
        await Future.delayed(Duration(seconds: 2));
        await tester.pump();
        expect(loadingFinder, findsNothing);
        expect(emailFinder, findsOneWidget);
        expect(passwordFinder, findsOneWidget);
        expect(loginFinder, findsOneWidget);
      });
    });

    testWidgets('Should LOGIN User', (WidgetTester tester) async {
      await tester.runAsync(() async {
        //Finders
        var loadingFinder = find.byType(CircularProgressIndicator);
        var emailFinder = find.byKey(ValueKey('email'));
        var passwordFinder = find.byKey(ValueKey('password'));
        var loginFinder = find.byKey(ValueKey('login'));
        var dashboardFinder = find.byKey(ValueKey('dashboard'));
        //Init app
        app.main();
        await tester.pump();
        //Get Base page
        await Future.delayed(Duration(seconds: 2));
        await tester.pump();
        expect(loadingFinder, findsOneWidget);
        //Should go to loading
        await Future.delayed(Duration(seconds: 2));
        await tester.pump();
        expect(loadingFinder, findsNothing);
        expect(emailFinder, findsOneWidget);
        expect(passwordFinder, findsOneWidget);
        expect(loginFinder, findsOneWidget);
        await tester.tap(loginFinder);
        await tester.pump();
        //Start loading
        await Future.delayed(Duration(seconds: 2));
        expect(loadingFinder, findsOneWidget);
        await tester.pump();
        //Should go to home
        await Future.delayed(Duration(seconds: 2));
        await tester.pump();
        expect(dashboardFinder, findsOneWidget);
      });
    });
  });
}
