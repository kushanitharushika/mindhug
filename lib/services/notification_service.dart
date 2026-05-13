import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart'; // for TimeOfDay
import '../core/storage/local_storage.dart';
import '../models/care_item.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  await NotificationService._handleNotificationAction(notificationResponse);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static Future<void> _handleNotificationAction(NotificationResponse response) async {
    if (response.actionId == 'yes_action') {
      final payload = response.payload;
      if (payload != null) {
        final items = await LocalStorage.getCareItems();
        final idx = items.indexWhere((item) => item.id == payload);
        if (idx != -1) {
          final item = items[idx];
          if (item.currentProgress < item.maxProgress) {
            final newItem = item.copyWith(
              currentProgress: item.currentProgress + 1,
              isCompleted: (item.currentProgress + 1) >= item.maxProgress,
            );
            items[idx] = newItem;
            await LocalStorage.saveCareItems(items);
            
            final service = NotificationService();
            tz.initializeTimeZones(); // Ensure tz is initialized in background
            if (newItem.isCompleted) {
              await service.cancelCareItemReminders(newItem.id);
            } else {
              await service.scheduleCareItemReminders(newItem);
            }
          }
        }
      }
    }
  }

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint("Could not set local timezone: $e");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await _handleNotificationAction(response);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_care_channel',
      'Daily Care Reminders',
      channelDescription: 'Reminders for your daily self-care tasks',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> scheduleHourlyNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await flutterLocalNotificationsPlugin.periodicallyShow(
      id: id,
      title: title,
      body: body,
      repeatInterval: RepeatInterval.hourly,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_care_channel',
          'Daily Care Reminders',
          channelDescription: 'Reminders for your daily self-care tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Helper for "Every 2 hours" - Since flutter_local_notifications doesn't have a 
  // built-in "every 2 hours" RepeatInterval, we can use hourly for now or schedule 
  // multiple specific times if needed. We'll stick to a simple periodic show.
  Future<void> scheduleTwoHourNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // We schedule it to run every hour, but in a real production app we would use 
    // workmanager or schedule multiple fixed times (e.g. 10am, 12pm, 2pm) using zonedSchedule.
    await flutterLocalNotificationsPlugin.periodicallyShow(
      id: id,
      title: title,
      body: body,
      repeatInterval: RepeatInterval.hourly, // Limitations of flutter_local_notifications 
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder_channel',
          'Hydration Reminders',
          channelDescription: 'Reminds you to drink water',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleDailyStroopReminder() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0); // 8:00 PM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // Check if they played today
    final lastPlayedStr = await LocalStorage.getLastStroopPlayedDate();
    if (lastPlayedStr != null) {
      try {
        final lastPlayed = DateTime.parse(lastPlayedStr);
        if (lastPlayed.year == now.year && lastPlayed.month == now.month && lastPlayed.day == now.day) {
          // They played today. So schedule for tomorrow at 8:00 PM
          if (scheduledDate.day == now.day) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }
        }
      } catch (e) {
        // Handle potential parsing errors
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 100, // Fixed ID for Stroop reminder
      title: 'Color Confusion Test',
      body: 'Have you played your daily Color Confusion test? Keep your brain sharp!',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_stroop_channel',
          'Daily Cognitive Reminders',
          channelDescription: 'Reminders to play the cognitive game',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat every day at 8:00 PM
    );
  }

  int _generateBaseId(String itemId) {
    return itemId.hashCode.abs() % 100000;
  }

  Future<void> scheduleCareItemReminders(CareItem item) async {
    // First, cancel any existing ones
    await cancelCareItemReminders(item.id);

    if (item.isCompleted || item.startTime == null || item.endTime == null) {
      return;
    }

    try {
      final TimeOfDay start = _parseTime(item.startTime!);
      final TimeOfDay end = _parseTime(item.endTime!);
      
      int startMinutes = start.hour * 60 + start.minute;
      int endMinutes = end.hour * 60 + end.minute;
      
      if (endMinutes <= startMinutes) {
        endMinutes += 24 * 60; // Handle crossing midnight
      }

      int totalMinutes = endMinutes - startMinutes;
      // We need to schedule 'target' number of reminders
      // e.g. target 5 means 5 notifications between start and end
      int target = item.maxProgress > 0 ? item.maxProgress : 1;
      
      // If the user already did some, we only schedule the remaining ones
      int remaining = target - item.currentProgress;
      if (remaining <= 0) return;

      int interval = totalMinutes ~/ target;
      
      int baseId = _generateBaseId(item.id);
      
      for (int i = 0; i < remaining; i++) {
        // Skip the ones already done by adjusting the start index
        int nthReminder = item.currentProgress + i;
        int scheduledMinutes = startMinutes + (nthReminder * interval);
        
        int sHour = (scheduledMinutes ~/ 60) % 24;
        int sMin = scheduledMinutes % 60;

        final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
        tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, sHour, sMin);
        
        if (scheduledDate.isBefore(now)) {
           scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: baseId + nthReminder,
          title: item.title,
          body: "Reminder: ${item.description}",
          scheduledDate: scheduledDate,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'custom_care_channel',
              'Custom Care Reminders',
              channelDescription: 'Your custom daily reminders',
              importance: Importance.high,
              priority: Priority.high,
              actions: item.type == 'counter' ? const <AndroidNotificationAction>[
                AndroidNotificationAction('yes_action', 'Yes', cancelNotification: true),
                AndroidNotificationAction('no_action', 'No', cancelNotification: true),
              ] : null,
            ),
          ),
          payload: item.id,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
        );
      }
    } catch (e) {
      debugPrint("Error scheduling care item: $e");
    }
  }

  Future<void> cancelCareItemReminders(String itemId) async {
    int baseId = _generateBaseId(itemId);
    // Assume max 50 reminders per item for cancellation
    for (int i = 0; i < 50; i++) {
      await flutterLocalNotificationsPlugin.cancel(id: baseId + i);
    }
  }

  TimeOfDay _parseTime(String timeString) {
    // Expects "10:30 AM" or "10:30" or similar
    // Simple parsing, assuming "HH:mm AM/PM" or "HH:mm"
    try {
      timeString = timeString.trim().toUpperCase();
      bool isPM = timeString.contains("PM");
      bool isAM = timeString.contains("AM");
      
      String timePart = timeString.replaceAll(RegExp(r'[A-Za-z\s]'), '');
      List<String> parts = timePart.split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 8, minute: 0); // fallback
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }
  
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
