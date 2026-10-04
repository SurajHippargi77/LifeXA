import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/dashboard/dashboard_screen.dart';
import 'package:frontend/screens/dashboard/widgets/today_section.dart';
import 'package:frontend/screens/splash/splash_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('LifeXA app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: AuthSession.instance),
        ],
        child: const LifeXAApp(),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump();

    expect(find.byType(LifeXAApp), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('splash logo fits a short viewport', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(728, 95);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const SplashScreen()),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('guest dashboard is responsive and prompts once', (tester) async {
    AuthSession.instance.clear();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: AuthSession.instance),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TodaySection), findsOneWidget);
    expect(find.text('Your tasks will appear here'), findsOneWidget);
    expect(find.text('LifeXA'), findsOneWidget);
    expect(find.text('Complete project report'), findsNothing);
    expect(find.text('Review ML assignment'), findsNothing);
    final desktopLayoutError = tester.takeException();
    if (desktopLayoutError != null) {
      fail(desktopLayoutError.toString());
    }

    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final mobileLayoutError = tester.takeException();
    if (mobileLayoutError != null) {
      fail(mobileLayoutError.toString());
    }

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.text('Welcome to LifeXA'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.text('Welcome to LifeXA'), findsNothing);
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
