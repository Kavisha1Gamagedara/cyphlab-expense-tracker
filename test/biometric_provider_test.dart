import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/data/services/biometric_service.dart';
import 'package:expense_tracker/presentation/state/biometric_provider.dart';

class FakeBiometricService extends BiometricService {
  final bool supported;
  final bool authResult;

  FakeBiometricService({this.supported = true, this.authResult = true});

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<bool> canCheckBiometrics() async => supported;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async =>
      [BiometricType.fingerprint];

  @override
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  }) async =>
      authResult;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BiometricProvider Tests', () {
    test('Defaults to disabled and authenticated when no prefs set', () {
      SharedPreferences.setMockInitialValues({});
      final provider = BiometricProvider(null, FakeBiometricService());

      expect(provider.isBiometricEnabled, isFalse);
      expect(provider.isAuthenticated, isTrue);
    });

    test('Loads enabled biometric lock from SharedPreferences as locked initially', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.biometricLockKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = BiometricProvider(prefs, FakeBiometricService());

      expect(provider.isBiometricEnabled, isTrue);
      expect(provider.isAuthenticated, isFalse);

      provider.unlockApp();
      expect(provider.isAuthenticated, isTrue);

      provider.lockApp();
      expect(provider.isAuthenticated, isFalse);
    });

    test('Toggles biometric lock with authentication successfully', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = BiometricProvider(prefs, FakeBiometricService(authResult: true));

      final success = await provider.toggleBiometricLock(
        enable: true,
        promptReason: 'Test enable',
      );

      expect(success, isTrue);
      expect(provider.isBiometricEnabled, isTrue);
      expect(prefs.getBool(AppConstants.biometricLockKey), isTrue);
    });
  });
}
