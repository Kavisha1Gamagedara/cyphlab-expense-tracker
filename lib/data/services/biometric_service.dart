import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service wrapping the official Flutter `local_auth` plugin.
/// Supports fingerprint, Face ID, and system credentials (PIN/pattern/passcode).
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  /// Check whether hardware is capable of checking biometrics
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on LocalAuthException catch (e) {
      debugPrint('[BiometricService] canCheckBiometrics LocalAuthException: ${e.code} - ${e.description}');
      return false;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] canCheckBiometrics PlatformException: $e');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] unexpected canCheckBiometrics error: $e');
      return false;
    }
  }

  /// Check if the device hardware supports biometrics or device credentials
  Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported || canCheck;
    } on LocalAuthException catch (e) {
      debugPrint('[BiometricService] isDeviceSupported LocalAuthException: ${e.code} - ${e.description}');
      return false;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] isDeviceSupported PlatformException: $e');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] unexpected isDeviceSupported error: $e');
      return false;
    }
  }

  /// Returns list of available enrolled biometrics (e.g. fingerprint, face)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on LocalAuthException catch (e) {
      debugPrint('[BiometricService] getAvailableBiometrics LocalAuthException: ${e.code} - ${e.description}');
      return <BiometricType>[];
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] getAvailableBiometrics PlatformException: $e');
      return <BiometricType>[];
    } catch (e) {
      debugPrint('[BiometricService] unexpected getAvailableBiometrics error: $e');
      return <BiometricType>[];
    }
  }

  /// Authenticate the user with biometrics or fallback device credentials (PIN/pattern).
  /// [persistAcrossBackgrounding] ensures auth prompt doesn't fail when app transitions
  /// to background during the prompt.
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      debugPrint('[BiometricService] authenticate LocalAuthException: ${e.code} - ${e.description}');
      return false;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] authenticate PlatformException: $e');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] authenticate unexpected error: $e');
      return false;
    }
  }

  /// Cancels any in-flight authentication
  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (e) {
      debugPrint('[BiometricService] stopAuthentication error: $e');
    }
  }
}
