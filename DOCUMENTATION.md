# Staff Complaint Management App - Documentation

## Table of Contents
1. [Existing Functionality](#existing-functionality)
2. [Architecture Overview](#architecture-overview)
3. [Firebase Cloud Messaging Implementation Plan](#firebase-cloud-messaging-implementation-plan)
4. [Backend Changes](#backend-changes)
5. [Frontend Changes](#frontend-changes)
6. [Testing Strategy](#testing-strategy)
7. [Deployment Checklist](#deployment-checklist)

---

## Existing Functionality

### Overview
The **Staff Complaint Management App** is a Flutter-based mobile/web application designed for staff members to manage customer service complaints. It provides a complete workflow for viewing, filtering, and updating complaint statuses.

### Current Features

#### 1. Authentication System
- **Login Screen** (`lib/screens/login_screen.dart`)
  - Username/password authentication
  - Token-based session management
  - Credential validation
  - Error handling with user feedback
  - Auto-login on app restart if session is valid

- **Session Management**
  - Uses `shared_preferences` for local storage
  - Stores user data and authentication token
  - Checks login status on app startup via splash screen
  - Automatic logout functionality

#### 2. Complaints Management

##### Complaints List Screen (`lib/screens/complaints_list_screen.dart`)
- Displays all complaints assigned to the logged-in staff member
- Features:
  - **Pull-to-refresh** functionality
  - **Status filtering** (All, Pending, Progressing, Resolved, Follow-up)
  - User profile display in app bar
  - Logout option
  - Empty state handling
  - Loading indicators

##### Complaint Detail Screen (`lib/screens/complaint_detail_screen.dart`)
- Shows comprehensive complaint information:
  - Job ID and status
  - Priority level (High, Medium, Low)
  - Customer information (Name, Phone, Address)
  - Complaint details (Type of Service, Device Type, Brand, Description)
  - Date created and closed date
  - Staff notes

- **Update Functionality:**
  - Change complaint status (Progressing, Resolved, Follow-up)
  - Add/edit staff notes
  - Save changes to server
  - Validation to prevent unnecessary updates

#### 3. Data Models

##### User Model (`lib/models/user.dart`)
```dart
- userId: int
- userName: String
- username: String
- roleId: int
- token: String
```

##### Complaint Model (`lib/models/complaint.dart`)
```dart
- complaintId: int
- jobId: String
- customerName: String
- customerPhone: String?
- customerAddress: String?
- complaintDate: String
- complaintStatus: String
- closedDate: String?
- priority: String (high/medium/low)
- complaintDescription: String
- notes: String?
- typeOfService: String?
- typeOfDevice: String?
- brand: String?
```

#### 4. API Integration (`lib/services/api_service.dart`)

**Base URL:** `servicedesk.infinityfreeapp.com`

**Endpoints:**
1. **Login:** `/api/staff_login.php`
   - Method: POST
   - Parameters: username, password
   - Returns: User object with token

2. **Get Complaints:** `/api/staff_complaints.php`
   - Method: POST
   - Headers: Authorization Bearer token
   - Parameters: user_id
   - Returns: List of complaints

3. **Update Complaint:** `/api/staff_update_complaint.php`
   - Method: POST
   - Headers: Authorization Bearer token
   - Parameters: complaint_id, status, notes
   - Returns: Success/failure response

#### 5. UI Components

##### Widgets
- **ComplaintCard** (`lib/widgets/complaint_card.dart`)
  - Displays complaint summary in list
  - Shows Job ID, customer name, description preview
  - Status and priority badges
  - Tappable to view details

- **StatusBadge** (`lib/widgets/status_badge.dart`)
  - Color-coded status indicators:
    - Orange: Pending
    - Blue: Progressing
    - Green: Resolved
    - Grey: Follow-up
    - Black: Closed

- **PriorityBadge** (`lib/widgets/status_badge.dart`)
  - Color-coded priority indicators:
    - Red: High
    - Orange: Medium
    - Green: Low

#### 6. App Theme & Design
- Material Design 3
- Custom color scheme (Primary: #2c3e50, Secondary: #34495e)
- Gradient splash screen
- Consistent card-based UI
- Responsive design for mobile and web

---

## Architecture Overview

### Current Architecture

```
┌─────────────────────────────────────────┐
│           Flutter App (Client)          │
├─────────────────────────────────────────┤
│  Screens                                │
│  ├── SplashScreen                       │
│  ├── LoginScreen                        │
│  ├── ComplaintsListScreen               │
│  └── ComplaintDetailScreen              │
├─────────────────────────────────────────┤
│  Services                               │
│  └── ApiService (HTTP Requests)         │
├─────────────────────────────────────────┤
│  Models                                 │
│  ├── User                               │
│  └── Complaint                          │
├─────────────────────────────────────────┤
│  Local Storage                          │
│  └── SharedPreferences (Token, User)    │
└─────────────────────────────────────────┘
                    ↓
              HTTP/HTTPS
                    ↓
┌─────────────────────────────────────────┐
│         PHP Backend (Server)            │
├─────────────────────────────────────────┤
│  API Endpoints                          │
│  ├── staff_login.php                    │
│  ├── staff_complaints.php               │
│  └── staff_update_complaint.php         │
├─────────────────────────────────────────┤
│           MySQL Database                │
└─────────────────────────────────────────┘
```

---

## Firebase Cloud Messaging Implementation Plan

### Overview
Implement Firebase Cloud Messaging (FCM) to enable real-time push notifications for staff members when:
1. New complaints are assigned to them
2. Complaint priority changes
3. Customer adds follow-up messages
4. Admin broadcasts important messages
5. Complaint status updates from other sources

### Architecture with FCM

```
┌─────────────────────────────────────────┐
│           Flutter App (Client)          │
├─────────────────────────────────────────┤
│  New: FCM Service                       │
│  ├── Initialize FCM                     │
│  ├── Request Permissions                │
│  ├── Get FCM Token                      │
│  ├── Handle Foreground Notifications    │
│  ├── Handle Background Notifications    │
│  └── Handle Notification Taps           │
└─────────────────────────────────────────┘
                    ↓
         FCM Token Registration
                    ↓
┌─────────────────────────────────────────┐
│         PHP Backend (Server)            │
├─────────────────────────────────────────┤
│  New: FCM Integration                   │
│  ├── Store FCM Tokens                   │
│  ├── Send Notifications via FCM API     │
│  └── Manage Notification Triggers       │
├─────────────────────────────────────────┤
│  New Database Tables                    │
│  ├── user_fcm_tokens                    │
│  └── notification_logs                  │
└─────────────────────────────────────────┘
                    ↓
         Firebase Cloud Messaging
                    ↓
┌─────────────────────────────────────────┐
│       Firebase Console/Admin SDK        │
│  ├── Project Configuration              │
│  ├── Service Account Keys               │
│  └── Notification Analytics             │
└─────────────────────────────────────────┘
```

---

## Frontend Changes

### 1. Dependencies to Add

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
  intl: ^0.18.1

  # New Firebase dependencies
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0  # For Android foreground notifications
```

### 2. Firebase Configuration

#### Files to Add:

**Android:** `android/app/google-services.json`
- Download from Firebase Console after creating project
- Place in `android/app/` directory

**iOS:** `ios/Runner/GoogleService-Info.plist`
- Download from Firebase Console
- Place in `ios/Runner/` directory

**Web:** Update `web/index.html` with Firebase SDK scripts

### 3. New Service: FCM Service

Create `lib/services/firebase_messaging_service.dart`:

```dart
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
          final data = json.decode(response.payload!);
          _navigateToComplaint(data);
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
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.messageId}');

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
    // Navigation logic will be implemented in main.dart
    // This will use a global navigator key
    final complaintId = data['complaint_id'];
    if (complaintId != null) {
      // Navigate to ComplaintDetailScreen
      print('Navigate to complaint: $complaintId');
    }
  }

  // Token refresh handler
  static Future<void> _onTokenRefresh(String newToken) async {
    _fcmToken = newToken;
    await _saveFCMTokenToServer(newToken);
  }

  // Get current FCM token
  static String? get fcmToken => _fcmToken;

  // Delete token on logout
  static Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    _fcmToken = null;
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.messageId}');
}
```

### 4. Update API Service

Add to `lib/services/api_service.dart`:

```dart
// Save FCM Token
static Future<Map<String, dynamic>> saveFCMToken(String fcmToken) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userJson = prefs.getString('user') ?? '';

    if (token.isEmpty || userJson.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    final user = json.decode(userJson);

    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/save_fcm_token.php'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      body: {
        'user_id': user['user_id'].toString(),
        'fcm_token': fcmToken,
        'device_type': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'web',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      return {'success': false, 'message': 'Server error'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Connection error: $e'};
  }
}

// Update logout to delete FCM token
static Future<void> logout() async {
  await FirebaseMessagingService.deleteToken();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
```

### 5. Update main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_messaging_service.dart';

// Add global navigator key for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM
  await FirebaseMessagingService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      navigatorKey: navigatorKey, // Add this
      debugShowCheckedModeBanner: false,
      // ... rest of the code
    );
  }
}
```

### 6. Update Login Screen

Add FCM initialization after successful login in `lib/screens/login_screen.dart`:

```dart
if (result['success'] == true) {
  // Initialize FCM after login
  await FirebaseMessagingService.initialize();

  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ComplaintsListScreen()),
    );
  }
}
```

### 7. Android Configuration

#### Update `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Change from 19 to 21
        targetSdkVersion flutter.targetSdkVersion
        multiDexEnabled true
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

#### Update `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### Update `android/app/build.gradle` (at the bottom):

```gradle
apply plugin: 'com.google.gms.google-services'
```

#### Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application>
        <!-- Add this for FCM -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="complaint_notifications" />

        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />
    </application>
</manifest>
```

### 8. iOS Configuration

#### Update `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 9. Web Configuration

Update `web/index.html`:

```html
<body>
  <!-- Firebase SDK -->
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js"></script>

  <script>
    // Your web app's Firebase configuration
    const firebaseConfig = {
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_AUTH_DOMAIN",
      projectId: "YOUR_PROJECT_ID",
      storageBucket: "YOUR_STORAGE_BUCKET",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      appId: "YOUR_APP_ID"
    };

    firebase.initializeApp(firebaseConfig);
  </script>

  <script src="main.dart.js" type="application/javascript"></script>
</body>
```

Create `web/firebase-messaging-sw.js`:

```javascript
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background message received:', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
```

---

## Backend Changes

### 1. New Database Tables

#### Table: `user_fcm_tokens`

```sql
CREATE TABLE user_fcm_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    fcm_token VARCHAR(255) NOT NULL UNIQUE,
    device_type ENUM('android', 'ios', 'web') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active TINYINT(1) DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_fcm_token (fcm_token)
);
```

#### Table: `notification_logs`

```sql
CREATE TABLE notification_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    complaint_id INT,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSON,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read TINYINT(1) DEFAULT 0,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_complaint_id (complaint_id)
);
```

### 2. New PHP File: `api/save_fcm_token.php`

```php
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once '../config/database.php';
require_once '../middleware/auth.php';

// Verify authentication
$auth = verifyToken();
if (!$auth['success']) {
    echo json_encode($auth);
    exit;
}

// Get POST data
$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
$fcm_token = isset($_POST['fcm_token']) ? trim($_POST['fcm_token']) : '';
$device_type = isset($_POST['device_type']) ? trim($_POST['device_type']) : 'android';

// Validate input
if ($user_id === 0 || empty($fcm_token)) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing required fields'
    ]);
    exit;
}

try {
    $db = new Database();
    $conn = $db->getConnection();

    // Check if token already exists for this user
    $stmt = $conn->prepare("
        SELECT id FROM user_fcm_tokens
        WHERE user_id = ? AND fcm_token = ?
    ");
    $stmt->bind_param("is", $user_id, $fcm_token);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Update existing token
        $stmt = $conn->prepare("
            UPDATE user_fcm_tokens
            SET device_type = ?, is_active = 1, updated_at = CURRENT_TIMESTAMP
            WHERE user_id = ? AND fcm_token = ?
        ");
        $stmt->bind_param("sis", $device_type, $user_id, $fcm_token);
    } else {
        // Insert new token
        $stmt = $conn->prepare("
            INSERT INTO user_fcm_tokens (user_id, fcm_token, device_type)
            VALUES (?, ?, ?)
        ");
        $stmt->bind_param("iss", $user_id, $fcm_token, $device_type);
    }

    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'FCM token saved successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to save FCM token'
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>
```

### 3. Backend Dependencies

#### Install Composer (if not already installed)

Composer is required for managing PHP dependencies.

**Windows:**
- Download and install from: https://getcomposer.org/download/

**Linux/Mac:**
```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

#### Create `backend/composer.json`

```json
{
    "name": "serviceapp/backend",
    "description": "Backend API for Service App with Firebase Cloud Messaging",
    "type": "project",
    "require": {
        "php": ">=7.4",
        "kreait/firebase-php": "^7.0"
    },
    "autoload": {
        "psr-4": {
            "ServiceApp\\": "services/"
        }
    }
}
```

#### Install Dependencies

```bash
cd backend
composer install
```

### 4. Firebase Service Account Setup

**IMPORTANT:** This implementation uses Firebase Admin SDK (modern approach) instead of the deprecated legacy FCM HTTP API.

#### Get Service Account Credentials

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Click the gear icon ⚙️ → **Project settings**
4. Go to **Service accounts** tab
5. Click **Generate new private key**
6. Download the JSON file (save as `firebase-service-account.json`)

**Security Warning:** Never commit this file to version control!

#### Configure Service Account Path

**Option A: Default location (development)**
```bash
# Place the file in backend/config/
backend/config/firebase-service-account.json
```

**Option B: Environment variable (production - recommended)**
```bash
export FIREBASE_SERVICE_ACCOUNT_PATH="/secure/path/to/firebase-service-account.json"
```

For web servers, add to `.htaccess` or server configuration:
```apache
SetEnv FIREBASE_SERVICE_ACCOUNT_PATH "/secure/path/to/firebase-service-account.json"
```

### 5. New PHP File: `backend/services/FCMService.php`

This file is now created using Firebase Admin SDK. The complete implementation is available in `backend/services/FCMService.php`.

**Key Features:**
- Uses modern Firebase Admin SDK
- Automatic invalid token cleanup
- Support for multicast messaging
- Topic-based notifications
- Better error handling
- Enhanced security

**Basic Usage:**

```php
<?php
require_once 'vendor/autoload.php';
require_once 'services/FCMService.php';

use ServiceApp\FCMService;

$fcmService = new FCMService();

// Send to single user
$result = $fcmService->sendToUser(
    $userId,
    "Notification Title",
    "Notification Body",
    ['complaint_id' => 123, 'type' => 'new_assignment']
);

// Send to multiple users (multicast - more efficient)
$tokens = ['token1', 'token2', 'token3'];
$result = $fcmService->sendMulticast(
    $tokens,
    "Broadcast Message",
    "Message body",
    ['type' => 'broadcast']
);
?>
```

For detailed usage examples, see `backend/api/notification_examples.php`.

### 6. Update Complaint Assignment/Update Logic

When a complaint is assigned or updated, trigger notification using the new FCMService:

Example in `api/assign_complaint.php` or similar:

```php
<?php
require_once '../vendor/autoload.php';
require_once '../services/FCMService.php';

use ServiceApp\FCMService;

// After assigning complaint in database
try {
    $fcmService = new FCMService();

    $title = "New Complaint Assigned";
    $body = "Job #" . $jobId . " has been assigned to you";
    $data = [
        'complaint_id' => $complaintId,
        'job_id' => $jobId,
        'type' => 'new_assignment',
        'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
    ];

    // Send notification using Firebase Admin SDK
    $result = $fcmService->sendToUser($staffUserId, $title, $body, $data);

    // Log notification if successful
    if ($result['success']) {
        $fcmService->logNotification(
            $staffUserId,
            $complaintId,
            'new_assignment',
            $title,
            $body,
            $data
        );
    }
} catch (Exception $e) {
    error_log("Notification error: " . $e->getMessage());
}
?>
```

### 7. Notification Triggers

**Note:** Complete working examples are available in `backend/api/notification_examples.php`

#### A. New Complaint Assignment

```php
function notifyNewComplaint($staffUserId, $complaintId, $jobId, $customerName) {
    use ServiceApp\FCMService;

    $fcmService = new FCMService();

    $title = "New Complaint Assigned";
    $body = "Job #{$jobId} from {$customerName} has been assigned to you";
    $data = [
        'complaint_id' => $complaintId,
        'job_id' => $jobId,
        'type' => 'new_assignment'
    ];

    $fcmService->sendToUser($staffUserId, $title, $body, $data);
    $fcmService->logNotification($staffUserId, $complaintId, 'new_assignment', $title, $body, $data);
}
```

#### B. Priority Change

```php
function notifyPriorityChange($staffUserId, $complaintId, $jobId, $newPriority) {
    $fcmService = new FCMService();

    $title = "Priority Updated";
    $body = "Job #{$jobId} priority changed to {$newPriority}";
    $data = [
        'complaint_id' => $complaintId,
        'job_id' => $jobId,
        'type' => 'priority_change',
        'priority' => $newPriority
    ];

    $fcmService->sendToUser($staffUserId, $title, $body, $data);
    $fcmService->logNotification($staffUserId, $complaintId, 'priority_change', $title, $body, $data);
}
```

#### C. Customer Follow-up

```php
function notifyCustomerFollowup($staffUserId, $complaintId, $jobId) {
    $fcmService = new FCMService();

    $title = "Customer Follow-up";
    $body = "Customer added a follow-up message for Job #{$jobId}";
    $data = [
        'complaint_id' => $complaintId,
        'job_id' => $jobId,
        'type' => 'customer_followup'
    ];

    $fcmService->sendToUser($staffUserId, $title, $body, $data);
    $fcmService->logNotification($staffUserId, $complaintId, 'customer_followup', $title, $body, $data);
}
```

#### D. Admin Broadcast

```php
function notifyAllStaff($title, $body) {
    $fcmService = new FCMService();

    // Get all staff user IDs
    $db = new Database();
    $conn = $db->getConnection();
    $result = $conn->query("SELECT user_id FROM users WHERE role_id = 2"); // Assuming role_id 2 is staff

    $staffIds = [];
    while ($row = $result->fetch_assoc()) {
        $staffIds[] = $row['user_id'];
    }

    $data = ['type' => 'broadcast'];

    $fcmService->sendToUser($staffIds, $title, $body, $data);

    // Log for each staff member
    foreach ($staffIds as $staffId) {
        $fcmService->logNotification($staffId, null, 'broadcast', $title, $body, $data);
    }
}
```

---

## Testing Strategy

### 1. Unit Testing

#### Test FCM Service
- Token registration
- Token update
- Token deletion
- Permission handling
- Foreground notification display
- Background notification handling
- Notification tap navigation

#### Test API Integration
- Save FCM token endpoint
- Token update on app restart
- Multiple devices per user
- Token cleanup on logout

### 2. Integration Testing

#### Test Notification Flow
1. **New Complaint Assignment**
   - Create complaint in backend
   - Verify notification received
   - Tap notification
   - Verify navigation to correct screen

2. **Foreground Notifications**
   - App in foreground
   - Trigger notification
   - Verify local notification displayed
   - Verify sound/vibration

3. **Background Notifications**
   - App in background
   - Trigger notification
   - Verify notification received
   - Tap notification
   - Verify app opens to correct screen

4. **App Terminated**
   - Kill app completely
   - Send notification
   - Tap notification
   - Verify app launches with correct deep link

### 3. Platform-Specific Testing

#### Android
- Test on Android 8.0+ (notification channels)
- Test on Android 13+ (runtime notification permission)
- Test different manufacturers (Samsung, Xiaomi, OnePlus)
- Test with battery optimization enabled/disabled

#### iOS
- Test permission prompt
- Test notification badges
- Test background fetch
- Test with Do Not Disturb mode

#### Web
- Test on Chrome/Firefox/Edge
- Test notification permission
- Test service worker
- Test browser notification settings

### 4. Edge Cases

- No internet connection during token registration
- Token refresh during app use
- Multiple device login
- Logout and re-login
- Token expiration
- FCM service unavailable
- Invalid tokens
- Large notification payloads

### 5. Performance Testing

- Token registration time
- Notification delivery latency
- Battery consumption
- Network usage
- Memory usage with multiple notifications

---

## Deployment Checklist

### Pre-Deployment

- [ ] Create Firebase project
- [ ] Download Firebase configuration files
- [ ] Update all configuration files with actual Firebase credentials
- [ ] Create database tables
- [ ] Deploy FCMService.php to backend
- [ ] Update API endpoints
- [ ] Test on development environment

### Firebase Configuration

- [ ] Enable Firebase Cloud Messaging in Firebase Console
- [ ] Generate and download service account key (for backend)
- [ ] Configure Firebase Analytics (optional)
- [ ] Set up notification topics (optional)
- [ ] Configure notification icons/colors

### Backend Deployment

- [ ] Upload new PHP files
- [ ] Run database migrations
- [ ] Configure Firebase Server Key as environment variable
- [ ] Test FCM token storage
- [ ] Test notification sending from backend
- [ ] Set up cron jobs (if needed for scheduled notifications)

### App Deployment

#### Android
- [ ] Update `minSdkVersion` to 21
- [ ] Add `google-services.json`
- [ ] Update AndroidManifest.xml
- [ ] Test APK/AAB build
- [ ] Test on physical devices
- [ ] Submit to Play Store (update if existing app)

#### iOS
- [ ] Add `GoogleService-Info.plist`
- [ ] Update Info.plist
- [ ] Enable push notifications capability in Xcode
- [ ] Upload APNs authentication key to Firebase Console
- [ ] Test on physical devices
- [ ] Submit to App Store (update if existing app)

#### Web
- [ ] Add Firebase scripts to index.html
- [ ] Create firebase-messaging-sw.js
- [ ] Test on localhost
- [ ] Test on deployed server
- [ ] Verify HTTPS is enabled (required for web notifications)

### Post-Deployment

- [ ] Monitor Firebase Console for notification delivery stats
- [ ] Check notification logs in database
- [ ] Gather user feedback
- [ ] Monitor crash reports
- [ ] Check battery impact
- [ ] Verify notification delivery rates

### Documentation

- [ ] Update user documentation
- [ ] Create notification settings guide for users
- [ ] Document backend API changes
- [ ] Update deployment guide
- [ ] Create troubleshooting guide

---

## Additional Features (Future Enhancements)

### 1. Notification Preferences
- Allow users to customize notification types
- Sound/vibration preferences
- Do Not Disturb schedule
- Notification grouping

### 2. In-App Notification Center
- View notification history
- Mark as read/unread
- Delete notifications
- Search notifications

### 3. Rich Notifications
- Images in notifications
- Action buttons (Accept, Reject, View)
- Expandable notifications with more details
- Custom notification sounds per priority

### 4. Notification Analytics
- Delivery rates
- Open rates
- User engagement metrics
- Failed notification tracking

### 5. Advanced Targeting
- Notification topics
- User segmentation
- Scheduled notifications
- Recurring notifications

---

## Troubleshooting Guide

### Common Issues

#### 1. Token Not Registering
**Symptoms:** FCM token is null or undefined
**Solutions:**
- Check Firebase configuration files
- Verify internet connection
- Check Firebase Console project settings
- Verify app permissions granted

#### 2. Notifications Not Received
**Symptoms:** No notifications appearing
**Solutions:**
- Verify FCM token saved in database
- Check backend notification sending logic
- Verify Firebase Server Key is correct
- Check device notification settings
- Verify app is not in battery optimization

#### 3. Foreground Notifications Not Showing (Android)
**Symptoms:** Notifications work in background but not foreground
**Solutions:**
- Verify local notifications initialized
- Check notification channel created
- Verify `onMessage` listener configured

#### 4. Notification Tap Not Working
**Symptoms:** Tapping notification doesn't open app or navigate
**Solutions:**
- Verify notification data includes proper fields
- Check navigation logic in `onMessageOpenedApp`
- Verify global navigator key configured

#### 5. iOS Permission Denied
**Symptoms:** User denied notification permission
**Solutions:**
- Prompt user to enable in Settings
- Show in-app explanation before requesting
- Provide manual instructions

---

## Security Considerations

### 1. Token Security
- Store FCM tokens securely in database
- Use HTTPS for all API calls
- Implement token rotation
- Clean up inactive tokens

### 2. Authentication
- Verify user authentication before saving tokens
- Use authorization headers
- Validate token ownership

### 3. Data Privacy
- Don't send sensitive data in notification payload
- Use data messages instead of notification messages for sensitive info
- Implement encryption for sensitive notifications
- Follow GDPR/privacy regulations

### 4. Backend Security
- Protect Firebase Server Key
- Use environment variables
- Implement rate limiting
- Validate all inputs
- Log all notification activities

---

## Maintenance

### Regular Tasks
- Clean up expired FCM tokens (monthly)
- Review notification logs (weekly)
- Monitor delivery rates (daily)
- Update Firebase SDK versions (quarterly)
- Review and optimize notification frequency

### Monitoring
- Track notification delivery success rate
- Monitor backend errors
- Check database storage growth
- Review user feedback
- Analyze notification engagement metrics

---

## Contact & Support

For questions or issues related to this implementation:
- Review this documentation
- Check Firebase documentation: https://firebase.google.com/docs/cloud-messaging
- Flutter Firebase documentation: https://firebase.flutter.dev
- Backend developer: [contact info]
- Frontend developer: [contact info]

---

## Changelog

### Version 1.0.0 (Current)
- Basic complaint management functionality
- Login/logout
- Complaint viewing and updating
- Status filtering

### Version 1.1.0 (Planned - Firebase Integration)
- Firebase Cloud Messaging integration
- Push notifications for new assignments
- Push notifications for priority changes
- Push notifications for customer follow-ups
- Notification logging
- Multi-device support

---

**Document Last Updated:** 2024-11-02
**Author:** AI Assistant
**Version:** 1.0
