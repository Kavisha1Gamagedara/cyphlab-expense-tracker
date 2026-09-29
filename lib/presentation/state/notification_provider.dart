import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../data/services/notification_service.dart';

/// Provider to manage app notification settings, daily reminder timer schedules,
/// and budget warning alerts.
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final SharedPreferences? _prefs;

  bool _isNotificationsEnabled = true;
  bool _isDailyReminderEnabled = true;
  int _reminderHour = 20; // Default 8:00 PM
  int _reminderMinute = 0;
  bool _isBudgetAlertsEnabled = true;

  NotificationProvider([this._prefs, NotificationService? service])
      : _notificationService = service ?? NotificationService() {
    _init();
  }

  bool get isNotificationsEnabled => _isNotificationsEnabled;
  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  TimeOfDay get reminderTime => TimeOfDay(hour: _reminderHour, minute: _reminderMinute);
  bool get isBudgetAlertsEnabled => _isBudgetAlertsEnabled;
  bool get isReminderToday => _notificationService.isScheduledForToday(_reminderHour, _reminderMinute);

  void _init() {
    if (_prefs != null) {
      _isNotificationsEnabled = _prefs.getBool(AppConstants.notificationsEnabledKey) ?? true;
      _isDailyReminderEnabled = _prefs.getBool(AppConstants.dailyReminderEnabledKey) ?? true;
      _reminderHour = _prefs.getInt(AppConstants.dailyReminderHourKey) ?? 20;
      _reminderMinute = _prefs.getInt(AppConstants.dailyReminderMinuteKey) ?? 0;
      _isBudgetAlertsEnabled = _prefs.getBool(AppConstants.budgetAlertsEnabledKey) ?? true;
    } else {
      _loadPrefsAsync();
    }
    // Initialize service in background
    _notificationService.initialize().then((_) {
      if (_isNotificationsEnabled && _isDailyReminderEnabled) {
        _rescheduleDailyReminder();
      }
    });
  }

  Future<void> _loadPrefsAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isNotificationsEnabled = prefs.getBool(AppConstants.notificationsEnabledKey) ?? true;
      _isDailyReminderEnabled = prefs.getBool(AppConstants.dailyReminderEnabledKey) ?? true;
      _reminderHour = prefs.getInt(AppConstants.dailyReminderHourKey) ?? 20;
      _reminderMinute = prefs.getInt(AppConstants.dailyReminderMinuteKey) ?? 0;
      _isBudgetAlertsEnabled = prefs.getBool(AppConstants.budgetAlertsEnabledKey) ?? true;
      notifyListeners();

      await _notificationService.initialize();
      if (_isNotificationsEnabled && _isDailyReminderEnabled) {
        await _rescheduleDailyReminder();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Error loading prefs: $e');
    }
  }

  /// Master switch for all notifications
  Future<bool> setNotificationsEnabled(bool enable) async {
    _isNotificationsEnabled = enable;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.notificationsEnabledKey, enable);

      if (enable) {
        final granted = await _notificationService.requestPermissions();
        if (_isDailyReminderEnabled) {
          await _rescheduleDailyReminder();
        }
        return granted;
      } else {
        await _notificationService.cancelAll();
        return true;
      }
    } catch (e) {
      debugPrint('[NotificationProvider] setNotificationsEnabled error: $e');
      return false;
    }
  }

  /// Daily reminder toggle
  Future<void> setDailyReminderEnabled(bool enable, {String? title, String? body}) async {
    _isDailyReminderEnabled = enable;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.dailyReminderEnabledKey, enable);

      if (enable && _isNotificationsEnabled) {
        await _notificationService.requestPermissions();
        await _rescheduleDailyReminder(title: title, body: body);
      } else {
        await _notificationService.cancel(1001);
      }
    } catch (e) {
      debugPrint('[NotificationProvider] setDailyReminderEnabled error: $e');
    }
  }

  /// Set the time for the scheduled daily reminder (Set Timer)
  Future<void> setReminderTime(TimeOfDay time, {String? title, String? body}) async {
    _reminderHour = time.hour;
    _reminderMinute = time.minute;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.dailyReminderHourKey, time.hour);
      await prefs.setInt(AppConstants.dailyReminderMinuteKey, time.minute);

      if (_isNotificationsEnabled && _isDailyReminderEnabled) {
        await _rescheduleDailyReminder(title: title, body: body);
      }
    } catch (e) {
      debugPrint('[NotificationProvider] setReminderTime error: $e');
    }
  }

  /// Budget warning alerts toggle
  Future<void> setBudgetAlertsEnabled(bool enable) async {
    _isBudgetAlertsEnabled = enable;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.budgetAlertsEnabledKey, enable);
    } catch (e) {
      debugPrint('[NotificationProvider] setBudgetAlertsEnabled error: $e');
    }
  }

  Future<void> _rescheduleDailyReminder({String? title, String? body}) async {
    await _notificationService.scheduleDailyNotification(
      id: 1001,
      title: title ?? 'Expense Reminder 📝',
      body: body ?? "Don't forget to record today's expenses!",
      hour: _reminderHour,
      minute: _reminderMinute,
    );
  }

  /// Trigger an immediate budget alert when an expense crosses 80% or 100%
  Future<void> sendBudgetAlert({
    required String title,
    required String body,
  }) async {
    if (!_isNotificationsEnabled || !_isBudgetAlertsEnabled) return;

    await _notificationService.showNotification(
      id: 2001,
      title: title,
      body: body,
      channelId: 'budget_alerts',
      channelName: 'Budget Alerts',
      channelDescription: 'Alerts when expenses exceed budget limits',
    );
  }

  /// Trigger recycle bin cleanup reminder
  Future<void> sendRecycleBinWarning({
    required String title,
    required String body,
  }) async {
    if (!_isNotificationsEnabled) return;

    await _notificationService.showNotification(
      id: 3001,
      title: title,
      body: body,
      channelId: 'recycle_bin_alerts',
      channelName: 'Recycle Bin Alerts',
      channelDescription: 'Warnings about items approaching deletion',
    );
  }

  /// Trigger a test notification
  Future<bool> sendTestNotification({
    required String title,
    required String body,
  }) async {
    await _notificationService.requestPermissions();
    await _notificationService.showNotification(
      id: 9999,
      title: title,
      body: body,
      channelId: 'test_channel',
      channelName: 'Test Notifications',
    );
    return true;
  }

  /// Schedule a quick test notification in [seconds] to verify background scheduler
  Future<void> scheduleTestTimer(int seconds, {required String title, required String body}) async {
    await _notificationService.requestPermissions();
    await _notificationService.scheduleNotificationInSeconds(
      id: 9998,
      title: title,
      body: body,
      seconds: seconds,
    );
  }
}
