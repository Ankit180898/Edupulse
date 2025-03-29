import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService extends GetxService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();
    
    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap here
        if (response.payload != null) {
          // Navigate to relevant screen based on payload
          print('Notification payload: ${response.payload}');
        }
      },
    );
  }

  Future<void> scheduleExamNotification(
    String id,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    // Skip if the date is in the past
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }
    
    // Android notification details
    AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      'exam_reminder_channel',
      'Exam Reminders',
      channelDescription: 'Notifications for exam reminders',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      playSound: true,
      enableVibration: true,
    );
    
    // iOS notification details
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      sound: 'notification_sound.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'exam_$id', // Payload to identify notification when tapped
    );
  }

  Future<void> cancelExamNotifications(String examId) async {
    // Cancel main exam notification
    await _notificationsPlugin.cancel(examId.hashCode);
    
    // Cancel reminder notifications
    await _notificationsPlugin.cancel("${examId}_day_before".hashCode);
    
    // Cancel any reminder notifications (up to 10 reminders)
    for (int i = 0; i < 10; i++) {
      await _notificationsPlugin.cancel("${examId}_reminder_$i".hashCode);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
  
  Future<void> requestNotificationPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
        
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}
