import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../data/services/biometric_service.dart';

/// Provider for managing Biometric Authentication (fingerprint / Face ID / PIN)
/// and securing the app against unauthorized access.
class BiometricProvider extends ChangeNotifier {
  final BiometricService _biometricService;
  final SharedPreferences? _prefs;

  bool _isBiometricEnabled = false;
  bool _isAuthenticated = true;
  bool _isDeviceSupported = false;
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isAuthenticating = false;
  String? _errorMessage;

  BiometricProvider([this._prefs, BiometricService? service])
      : _biometricService = service ?? BiometricService() {
    _init();
  }

  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isAuthenticated => _isAuthenticated;
  bool get isDeviceSupported => _isDeviceSupported;
  bool get canCheckBiometrics => _canCheckBiometrics;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  bool get isAuthenticating => _isAuthenticating;
  String? get errorMessage => _errorMessage;

  /// Returns true if device has fingerprint / strong biometric enrolled
  bool get hasFingerprint =>
      _availableBiometrics.contains(BiometricType.fingerprint) ||
      _availableBiometrics.contains(BiometricType.strong);

  /// Returns true if device has facial recognition enrolled
  bool get hasFace =>
      _availableBiometrics.contains(BiometricType.face);

  void _init() {
    if (_prefs != null) {
      _isBiometricEnabled = _prefs.getBool(AppConstants.biometricLockKey) ?? false;
      // If biometric lock is disabled, user is automatically authenticated
      _isAuthenticated = !_isBiometricEnabled;
    } else {
      _loadPrefsAsync();
    }
    checkHardwareSupport();
  }

  Future<void> _loadPrefsAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isBiometricEnabled = prefs.getBool(AppConstants.biometricLockKey) ?? false;
      _isAuthenticated = !_isBiometricEnabled;
      notifyListeners();
    } catch (e) {
      debugPrint('[BiometricProvider] Error loading prefs: $e');
    }
  }

  /// Check hardware and enrolled biometrics
  Future<void> checkHardwareSupport() async {
    try {
      _isDeviceSupported = await _biometricService.isDeviceSupported();
      _canCheckBiometrics = await _biometricService.canCheckBiometrics();
      _availableBiometrics = await _biometricService.getAvailableBiometrics();
      notifyListeners();
    } catch (e) {
      debugPrint('[BiometricProvider] checkHardwareSupport error: $e');
    }
  }

  /// Authenticate the user. Returns true if successful.
  Future<bool> authenticate({
    String localizedReason = 'Authenticate to access TRACE',
  }) async {
    if (_isAuthenticating) return false;

    _isAuthenticating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _biometricService.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false, // Allows device PIN/pattern fallback
      );

      if (success) {
        _isAuthenticated = true;
        _errorMessage = null;
      } else {
        _errorMessage = 'Authentication failed';
      }
      _isAuthenticating = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticating = false;
      notifyListeners();
      return false;
    }
  }

  /// Enable or disable biometric lock.
  /// If enabling: prompts authentication first to verify credentials.
  /// If disabling: prompts authentication to verify owner identity.
  Future<bool> toggleBiometricLock({
    required bool enable,
    required String promptReason,
  }) async {
    // If setting to same value, nothing to do
    if (_isBiometricEnabled == enable) return true;

    // Verify authentication before changing security setting
    final authSuccess = await authenticate(localizedReason: promptReason);
    if (!authSuccess) {
      return false;
    }

    _isBiometricEnabled = enable;
    _isAuthenticated = true; // Still authenticated in current session
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.biometricLockKey, enable);
    } catch (e) {
      debugPrint('[BiometricProvider] Error saving biometric preference: $e');
    }

    return true;
  }

  /// Locks the app (e.g. when app resumes or goes to background).
  /// Only locks if biometric lock is actually enabled and we are not currently
  /// mid-authentication.
  void lockApp() {
    if (_isBiometricEnabled && !_isAuthenticating) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  /// Force unlock (e.g. on test or bypass if needed)
  void unlockApp() {
    _isAuthenticated = true;
    notifyListeners();
  }
}
