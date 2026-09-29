import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants.dart';
import 'firebase_options.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/biometric_lock_screen.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/biometric_provider.dart';
import 'presentation/state/currency_provider.dart';
import 'presentation/state/expense_provider.dart';
import 'presentation/state/language_provider.dart';
import 'presentation/state/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences? prefs;
  const MyApp({super.key, this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final BiometricProvider _biometricProvider;

  @override
  void initState() {
    super.initState();
    _biometricProvider = BiometricProvider(widget.prefs);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _biometricProvider.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Lock app when minimized / backgrounded if biometric lock is turned on
      if (_biometricProvider.isBiometricEnabled && !_biometricProvider.isAuthenticating) {
        _biometricProvider.lockApp();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(widget.prefs)),
        ChangeNotifierProvider(create: (_) => LanguageProvider(widget.prefs)),
        ChangeNotifierProvider(create: (_) => CurrencyProvider(widget.prefs)),
        ChangeNotifierProvider.value(value: _biometricProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: Consumer4<ThemeProvider, LanguageProvider, CurrencyProvider, BiometricProvider>(
        builder: (context, themeProvider, languageProvider, currencyProvider, biometricProvider, child) {
          final authProvider = context.watch<AuthProvider>();
          final isLocked = authProvider.isAuthenticated &&
              biometricProvider.isBiometricEnabled &&
              !biometricProvider.isAuthenticated;

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            builder: (context, appChild) {
              return Stack(
                children: [
                  if (appChild != null)
                    AbsorbPointer(
                      absorbing: isLocked,
                      child: FocusScope(
                        canRequestFocus: !isLocked,
                        child: appChild,
                      ),
                    ),
                  if (isLocked)
                    const Positioned.fill(
                      child: BiometricLockScreen(),
                    ),
                ],
              );
            },
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
