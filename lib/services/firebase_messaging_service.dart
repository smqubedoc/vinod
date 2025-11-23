import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static String? _fcmToken;

  // Initialize Firebase and FCM
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');

        // Get FCM token
        _fcmToken = await _firebaseMessaging.getToken();
        print('FCM Token: $_fcmToken');

        // Save token to backend
        if (_fcmToken != null) {
          await _saveFCMTokenToServer(_fcmToken!);
        }

        // Initialize local notifications for Android
        await _initializeLocalNotifications();

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // Handle notification tap when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Handle notification tap when app was terminated
        RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  // Initialize local notifications for Android foreground
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap from local notification
        if (response.payload != null) {
          try {
            final data = json.decode(response.payload!);
            _navigateToComplaint(data);
          } catch (e) {
            print('Error parsing notification payload: $e');
          }
        }
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'complaint_notifications',
      'Complaint Notifications',
      description: 'Notifications for complaint updates',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Save FCM token to server
  static Future<void> _saveFCMTokenToServer(String token) async {
    try {
      final result = await ApiService.saveFCMToken(token);
      if (result['success'] == true) {
        print('FCM token saved to server');
      } else {
        print('Failed to save FCM token: ${result['message']}');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Show local notification
    await _showLocalNotification(message);
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'complaint_notifications',
      'Complaint Notifications',
      channelDescription: 'Notifications for complaint updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.notification.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: json.encode(message.data),
    );
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    _navigateToComplaint(message.data);
  }

  // Navigate to complaint detail
  static void _navigateToComplaint(Map<String, dynamic> data) {
    // Navigation logic will be implemented via callback or global navigator
    final complaintId = data['complaint_id'];
    if (complaintId != null) {
      print('Navigate to complaint: $complaintId');
      // This will be handled by the app's navigation system
      // We'll set up a callback in main.dart
    }
  }

  // Token refresh handler
  static Future<void> _onTokenRefresh(String newToken) async {
    print('FCM Token refreshed: $newToken');
    _fcmToken = newToken;
    await _saveFCMTokenToServer(newToken);
  }

  // Get current FCM token
  static String? get fcmToken => _fcmToken;

  // Delete token on logout
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      print('FCM token deleted');
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}
