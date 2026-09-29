import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/data/services/notification_service.dart';
import 'package:expense_tracker/presentation/state/notification_provider.dart';

class FakeNotificationService extends NotificationService {
  bool initialized = false;
  int cancelCount = 0;
  List<Map<String, dynamic>> scheduledNotifications = [];
  List<Map<String, dynamic>> sentNotifications = [];

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> cancel(int id) async {
    cancelCount++;
  }

  @override
  Future<void> cancelAll() async {
    cancelCount++;
    scheduledNotifications.clear();
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
    String? channelName,
    String? channelDescription,
    String? payload,
    dynamic importance,
    dynamic priority,
  }) async {
    sentNotifications.add({'id': id, 'title': title, 'body': body});
  }

  @override
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'hour': hour,
      'minute': minute,
    });
  }

  @override
  bool isScheduledForToday(int hour, int minute) => true;

  @override
  Future<void> scheduleNotificationInSeconds({
    required int id,
    required String title,
    required String body,
    required int seconds,
  }) async {
    scheduledNotifications.add({'id': id, 'title': title, 'seconds': seconds});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationProvider Tests', () {
    test('Initializes with default settings', () {
      SharedPreferences.setMockInitialValues({});
      final fakeService = FakeNotificationService();
      final provider = NotificationProvider(null, fakeService);

      expect(provider.isNotificationsEnabled, isTrue);
      expect(provider.isDailyReminderEnabled, isTrue);
      expect(provider.reminderHour, 20);
      expect(provider.reminderMinute, 0);
      expect(provider.reminderTime, const TimeOfDay(hour: 20, minute: 0));
      expect(provider.isBudgetAlertsEnabled, isTrue);
    });

    test('Loads preferences from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.notificationsEnabledKey: false,
        AppConstants.dailyReminderEnabledKey: true,
        AppConstants.dailyReminderHourKey: 9,
        AppConstants.dailyReminderMinuteKey: 30,
        AppConstants.budgetAlertsEnabledKey: false,
      });
      final prefs = await SharedPreferences.getInstance();
      final fakeService = FakeNotificationService();
      final provider = NotificationProvider(prefs, fakeService);

      expect(provider.isNotificationsEnabled, isFalse);
      expect(provider.reminderHour, 9);
      expect(provider.reminderMinute, 30);
      expect(provider.isBudgetAlertsEnabled, isFalse);
    });

    test('Updating reminder time persists and reschedules notification', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fakeService = FakeNotificationService();
      final provider = NotificationProvider(prefs, fakeService);

      await provider.setReminderTime(
        const TimeOfDay(hour: 21, minute: 15),
        title: 'Daily Check',
        body: 'Log expenses',
      );

      expect(provider.reminderHour, 21);
      expect(provider.reminderMinute, 15);
      expect(prefs.getInt(AppConstants.dailyReminderHourKey), 21);
      expect(prefs.getInt(AppConstants.dailyReminderMinuteKey), 15);
      expect(fakeService.scheduledNotifications.isNotEmpty, isTrue);
      expect(fakeService.scheduledNotifications.last['hour'], 21);
      expect(fakeService.scheduledNotifications.last['minute'], 15);
    });

    test('Sending budget alert triggers showNotification when enabled', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fakeService = FakeNotificationService();
      final provider = NotificationProvider(prefs, fakeService);

      await provider.sendBudgetAlert(
        title: 'Budget Alert',
        body: 'Over 80%',
      );

      expect(fakeService.sentNotifications.length, 1);
      expect(fakeService.sentNotifications.first['title'], 'Budget Alert');
    });

    test('Master disable cancels notifications and suppresses alerts', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fakeService = FakeNotificationService();
      final provider = NotificationProvider(prefs, fakeService);

      await provider.setNotificationsEnabled(false);
      expect(provider.isNotificationsEnabled, isFalse);
      expect(prefs.getBool(AppConstants.notificationsEnabledKey), isFalse);

      await provider.sendBudgetAlert(
        title: 'Budget Alert',
        body: 'Over 80%',
      );
      expect(fakeService.sentNotifications.isEmpty, isTrue);
    });
  });
}
