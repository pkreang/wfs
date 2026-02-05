import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
    );

    _initialized = true;
  }

  /// Request notification permissions (iOS 13+ and Android 13+)
  Future<bool?> requestPermissions() async {
    if (!_initialized) await initialize();

    // For Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.requestNotificationsPermission();
    }

    // For iOS
    final IOSFlutterLocalNotificationsPlugin? iosImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      return await iosImplementation.requestPermissions(alert: true, badge: true, sound: true);
    }

    return null;
  }

  /// Show instant notification
  Future<void> showNotification({required int id, required String title, required String body, String? payload, NotificationDetails? notificationDetails}) async {
    if (!_initialized) await initialize();

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails:
          notificationDetails ??
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default Notifications',
              channelDescription: 'Default notification channel',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: true,
            ),
            iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
          ),
      payload: payload,
    );
  }

  /// Schedule notification
  Future<void> scheduleNotification({required int id, required String title, required String body, required DateTime scheduledDate, String? payload, NotificationDetails? notificationDetails}) async {
    if (!_initialized) await initialize();

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails:
          notificationDetails ??
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'scheduled_channel',
              'Scheduled Notifications',
              channelDescription: 'Scheduled notification channel',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
          ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Schedule periodic notification
  Future<void> schedulePeriodicNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    if (!_initialized) await initialize();

    await _notificationsPlugin.periodicallyShow(
      id: id,
      title: title,
      body: body,
      repeatInterval: repeatInterval,
      notificationDetails:
          notificationDetails ??
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'periodic_channel',
              'Periodic Notifications',
              channelDescription: 'Periodic notification channel',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
          ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Get active notifications (Android 6+, iOS 10+)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    return await _notificationsPlugin.getActiveNotifications();
  }

  // Callback handlers
  void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    // Handle notification tap
    final String? payload = notificationResponse.payload;
    print('Notification tapped with payload: $payload');

    // TODO: Implement navigation or action based on payload
    // Example: Navigate to specific page based on payload
  }

  @pragma('vm:entry-point')
  static void _onDidReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse) {
    // Handle notification tap in background
    final String? payload = notificationResponse.payload;
    print('Background notification tapped with payload: $payload');

    // TODO: Implement background action handling
  }
}
