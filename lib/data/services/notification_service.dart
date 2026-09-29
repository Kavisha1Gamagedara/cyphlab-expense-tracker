import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service wrapping `flutter_local_notifications` for instant alerts,
/// scheduled daily reminders, and budget warnings with accurate device timezone support.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _notificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool get isInitialized => _isInitialized;

  /// Initialize notifications plugin and set the device's native timezone
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Timezone database
      tz.initializeTimeZones();

      // 2. Fetch and set device's actual local timezone
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        final String currentTimeZone = timezoneInfo.identifier;
        tz.setLocalLocation(tz.getLocation(currentTimeZone));
        debugPrint('[NotificationService] Local timezone configured: $currentTimeZone');
      } catch (e) {
        debugPrint('[NotificationService] FlutterTimezone error: $e. Falling back to offset match.');
        _fallbackTimezoneByOffset();
      }

      // 3. Platform initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('[NotificationService] Notification tapped: ${response.payload}');
        },
      );

      // Create Android Notification Channels proactively
      await _createNotificationChannels();

      _isInitialized = true;
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  /// Match device offset if named timezone lookup failed
  void _fallbackTimezoneByOffset() {
    try {
      final offset = DateTime.now().timeZoneOffset;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == offset) {
          tz.setLocalLocation(loc);
          debugPrint('[NotificationService] Fallback timezone set to: ${loc.name}');
          return;
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] Fallback offset error: $e');
    }
  }

  /// Create high-priority notification channels on Android
  Future<void> _createNotificationChannels() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    const dailyChannel = AndroidNotificationChannel(
      'daily_reminders',
      'Daily Reminders',
      description: 'Daily reminders to log your expenses',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const budgetChannel = AndroidNotificationChannel(
      'budget_alerts',
      'Budget Alerts',
      description: 'Alerts when expenses exceed or approach limits',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const generalChannel = AndroidNotificationChannel(
      'default_channel',
      'General Alerts',
      description: 'General expense tracker updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await androidPlugin.createNotificationChannel(dailyChannel);
    await androidPlugin.createNotificationChannel(budgetChannel);
    await androidPlugin.createNotificationChannel(generalChannel);
  }

  /// Request notification & exact alarm permissions on Android 12+ / 13+ and iOS
  Future<bool> requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        // 1. Request POST_NOTIFICATIONS (Android 13+)
        final notifGranted = await androidPlugin?.requestNotificationsPermission() ?? false;

        // 2. Request Exact Alarms Permission (Android 12+) for reliable scheduled reminders
        final canScheduleExact = await androidPlugin?.canScheduleExactNotifications() ?? true;
        if (!canScheduleExact) {
          await androidPlugin?.requestExactAlarmsPermission();
        }

        return notifGranted;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('[NotificationService] Permission request error: $e');
      return false;
    }
  }

  /// Cancel specific notification by ID
  Future<void> cancel(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('[NotificationService] Cancel error: $e');
    }
  }

  /// Cancel all active and scheduled notifications
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('[NotificationService] CancelAll error: $e');
    }
  }

  /// Show an immediate notification (e.g. Budget warnings, test alerts)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
    String? channelName,
    String? channelDescription,
    String? payload,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
  }) async {
    if (!_isInitialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      channelId ?? 'default_channel',
      channelName ?? 'Expense Alerts',
      channelDescription: channelDescription ?? 'Expense Tracker Notifications',
      importance: importance,
      priority: priority,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] Show notification error: $e');
    }
  }

  /// Schedule daily recurring reminder at the specified hour and minute
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    final scheduledDate = _nextInstanceOfTime(hour, minute);
    debugPrint('[NotificationService] Scheduled date: $scheduledDate (Now is: ${tz.TZDateTime.now(tz.local)})');

    const androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      'Daily Reminders',
      channelDescription: 'Daily reminder to log expenses',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      // First cancel existing to prevent duplicate scheduled entries
      await _notificationsPlugin.cancel(id: id);

      // Check exact alarm eligibility
      bool canExact = true;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        canExact = (await androidPlugin?.canScheduleExactNotifications()) ?? false;
      }

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      debugPrint('[NotificationService] Successfully registered daily reminder for $hour:$minute (exact=$canExact) at $scheduledDate');
    } catch (e) {
      debugPrint('[NotificationService] scheduleDailyNotification error: $e');
    }
  }

  /// Schedule a one-time test notification in [seconds] seconds
  Future<void> scheduleNotificationInSeconds({
    required int id,
    required String title,
    required String body,
    required int seconds,
  }) async {
    if (!_isInitialized) await initialize();

    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

    const androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      'Daily Reminders',
      channelDescription: 'Test notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notificationsPlugin.cancel(id: id);

      bool canExact = true;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        canExact = (await androidPlugin?.canScheduleExactNotifications()) ?? false;
      }

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
      debugPrint('[NotificationService] Scheduled test notification in $seconds seconds at $scheduledDate');
    } catch (e) {
      debugPrint('[NotificationService] scheduleNotificationInSeconds error: $e');
    }
  }

  /// Calculate next instance of a specific hour:minute in the local timezone
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0, // 00 seconds
    );

    // If the scheduled time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Check whether the scheduled time is today or tomorrow
  bool isScheduledForToday(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );
    return scheduled.isAfter(now);
  }
}
