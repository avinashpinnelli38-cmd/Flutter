import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'providers/fuel_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isDarkMode = false;
  final fuelProvider = FuelProvider();
  final profileProvider = ProfileProvider();

  try {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
  } catch (e) {
    debugPrint('SharedPreferences error: $e');
  }

  try {
    await profileProvider.load();
  } catch (e) {
    debugPrint('Profile load error: $e');
  }

  try {
    final userId = profileProvider.userId;
    if (profileProvider.isLoggedIn && userId != null) {
      await fuelProvider.setCurrentUser(userId);
    } else {
      fuelProvider.clearSession();
    }
  } catch (e) {
    debugPrint('Fuel data load error: $e');
  }

  runApp(
    MyApp(
      initialDarkMode: isDarkMode,
      fuelProvider: fuelProvider,
      profileProvider: profileProvider,
    ),
  );
}

/// Building a `ThemeData` with `GoogleFonts` walks the whole text theme and is
/// far too costly to redo on every rebuild, so it is resolved once up front.
ThemeData? _lightTheme;
ThemeData? _darkTheme;

ThemeData get _appLightTheme =>
    _lightTheme ??= AppTheme.lightTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(AppTheme.lightTheme.textTheme),
    );

ThemeData get _appDarkTheme =>
    _darkTheme ??= AppTheme.darkTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(AppTheme.darkTheme.textTheme),
    );

class MyApp extends StatelessWidget {
  final bool initialDarkMode;
  final FuelProvider fuelProvider;
  final ProfileProvider profileProvider;
  const MyApp({
    super.key,
    required this.initialDarkMode,
    required this.fuelProvider,
    required this.profileProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: fuelProvider),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialDarkMode)),
      ],
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return Selector<ThemeProvider, ThemeMode>(
            selector: (_, themeProvider) => themeProvider.themeMode,
            builder: (context, themeMode, _) {
              return MaterialApp(
                title: 'Fuel Consumption Tracker',
                debugShowCheckedModeBanner: false,
                theme: _appLightTheme,
                darkTheme: _appDarkTheme,
                themeMode: themeMode,
                home: profileProvider.isLoggedIn
                    ? const HomeScreen()
                    : const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
