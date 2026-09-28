import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'firebase_options.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/expense_provider.dart';
import 'presentation/state/language_provider.dart';
import 'presentation/state/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

/// Dynamic gate that decides whether to show the Dashboard, Onboarding, or Auth screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // If authenticated:
    if (authProvider.isAuthenticated) {
      // If newly registered, show the 3 random onboarding screens first
      if (authProvider.needsOnboarding) {
        return const OnboardingScreen();
      }
      return const MainNavigationScreen();
    }

    // Otherwise show the login / sign up screen
    return const AuthScreen();
  }
}
