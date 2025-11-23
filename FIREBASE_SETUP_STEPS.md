# Firebase Cloud Messaging Setup - Next Steps

## What Has Been Completed

✅ **Flutter Code Implementation**
- Added Firebase dependencies to `pubspec.yaml`
- Created `FirebaseMessagingService` class for handling notifications
- Updated `ApiService` to save FCM tokens to backend
- Updated `main.dart` to initialize Firebase
- Updated `LoginScreen` to initialize FCM after login
- Configured Android build files for FCM support
- Updated AndroidManifest.xml with necessary permissions

## What You Need to Do Next

### Step 1: Install Dependencies

First, stop the running app and install the new dependencies:

```bash
# Stop the current app (press 'q' in the terminal where it's running)

# Install dependencies
flutter pub get
```

### Step 2: Create Firebase Project

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com
   - Sign in with your Google account
   - Click "Add project" or select an existing project

2. **Add Your App to Firebase Project**

   **For Android:**
   - Click the Android icon in Firebase Console
   - Enter package name: `com.example.complaint_staff_app`
   - Enter app nickname: "Complaint Staff App"
   - Download `google-services.json`
   - Place it in: `android/app/google-services.json`

   **For iOS (if needed):**
   - Click the iOS icon in Firebase Console
   - Enter bundle ID
   - Download `GoogleService-Info.plist`
   - Place it in: `ios/Runner/GoogleService-Info.plist`

   **For Web (if needed):**
   - Click the Web icon in Firebase Console
   - Register your app
   - Copy the Firebase configuration

3. **Enable Firebase Cloud Messaging**
   - In Firebase Console, go to "Build" > "Cloud Messaging"
   - Note down your Server Key (needed for backend)

### Step 3: Update Firebase Configuration

**Option A: Manual Configuration**

Edit `lib/firebase_options.dart` and replace the placeholder values with your actual Firebase configuration from Firebase Console:

```dart
// Replace these with your actual values from Firebase Console
static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',           // From Firebase Console
    appId: 'YOUR_ANDROID_APP_ID',             // From Firebase Console
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',  // From Firebase Console
    projectId: 'YOUR_PROJECT_ID',             // From Firebase Console
    storageBucket: 'YOUR_STORAGE_BUCKET',     // From Firebase Console
);
```

**Option B: Automatic Configuration (Recommended)**

Install FlutterFire CLI and auto-configure:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run configuration (this will auto-generate firebase_options.dart)
flutterfire configure
```

This will automatically:
- Detect your Firebase projects
- Let you select/create a project
- Generate the correct `firebase_options.dart` file
- Set up configuration for all platforms

### Step 4: Backend Setup

You need to implement the backend PHP files to handle FCM tokens and send notifications.

#### 4.1 Create Database Tables

Run these SQL commands on your MySQL database:

```sql
-- Table to store FCM tokens
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

-- Table to log notifications
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

#### 4.2 Create Backend Files

Create these PHP files on your backend server:

1. **api/save_fcm_token.php** - To save FCM tokens
2. **services/FCMService.php** - To send notifications

📄 **Refer to DOCUMENTATION.md** for complete backend code examples (search for "Backend Changes" section).

#### 4.3 Configure Firebase Server Key

You need to add your Firebase Server Key to the backend:

**Get Server Key:**
1. Go to Firebase Console
2. Project Settings > Cloud Messaging
3. Copy the "Server key"

**Add to Backend:**
- Store in environment variable: `FIREBASE_SERVER_KEY`
- Or add directly to `services/FCMService.php` (line ~11)

### Step 5: Test the Implementation

#### 5.1 Run Flutter App

```bash
# Make sure dependencies are installed
flutter pub get

# Run on Android device/emulator
flutter run -d android

# OR run on web
flutter run -d chrome
```

#### 5.2 Test FCM Token Registration

1. Run the app
2. Login with valid credentials
3. Check the console/logs for:
   ```
   Firebase initialized successfully
   User granted permission
   FCM Token: [your_token_here]
   FCM token saved to server
   ```

4. Verify in database that token is saved in `user_fcm_tokens` table

#### 5.3 Test Notification Sending (Backend)

Create a test PHP script to send a notification:

```php
<?php
require_once 'services/FCMService.php';

$fcmService = new FCMService();

$userId = 1; // Replace with actual user ID
$title = "Test Notification";
$body = "This is a test notification from Firebase";
$data = [
    'type' => 'test',
    'complaint_id' => 123
];

$result = $fcmService->sendToUser($userId, $title, $body, $data);
print_r($result);
?>
```

### Step 6: Troubleshooting

#### Issue: "User declined or has not accepted permission"
**Solution:** The user needs to grant notification permission. On Android 13+, this is a runtime permission.

#### Issue: "Error initializing Firebase"
**Solution:**
- Check that `google-services.json` is in the correct location
- Verify Firebase configuration in `firebase_options.dart`
- Make sure package name matches

#### Issue: "FCM token is null"
**Solution:**
- Check internet connection
- Verify Firebase project is configured correctly
- Check Firebase Console for any errors

#### Issue: Notifications not received
**Solution:**
- Verify FCM token is saved in database
- Check Firebase Server Key is correct
- Test with Firebase Console's "Cloud Messaging" test feature
- Check device notification settings

### Step 7: Platform-Specific Setup

#### Android Additional Steps
1. Make sure `google-services.json` is in `android/app/`
2. Build and test on physical device (notifications don't work on emulators without Google Play Services)

#### iOS Additional Steps (if deploying to iOS)
1. Add `GoogleService-Info.plist` to `ios/Runner/`
2. Enable Push Notifications capability in Xcode
3. Upload APNs key to Firebase Console
4. Update `Info.plist` with background modes

#### Web Additional Steps (if deploying to Web)
1. Update `web/index.html` with Firebase SDK scripts
2. Create `web/firebase-messaging-sw.js` service worker
3. Ensure site is served over HTTPS

📄 **See DOCUMENTATION.md** for detailed platform-specific code.

## Summary of Files Modified

### Created Files:
- ✅ `lib/services/firebase_messaging_service.dart`
- ✅ `lib/firebase_options.dart` (needs actual config)
- ✅ `FIREBASE_SETUP_STEPS.md` (this file)

### Modified Files:
- ✅ `pubspec.yaml`
- ✅ `lib/main.dart`
- ✅ `lib/services/api_service.dart`
- ✅ `lib/screens/login_screen.dart`
- ✅ `android/build.gradle.kts`
- ✅ `android/app/build.gradle.kts`
- ✅ `android/app/src/main/AndroidManifest.xml`

### Files You Need to Add:
- ⏳ `android/app/google-services.json` (from Firebase Console)
- ⏳ Backend: `api/save_fcm_token.php`
- ⏳ Backend: `services/FCMService.php`
- ⏳ Backend: Database tables (SQL migrations)

## Quick Start Checklist

- [ ] Stop running app
- [ ] Run `flutter pub get`
- [ ] Create Firebase project
- [ ] Download `google-services.json`
- [ ] Place `google-services.json` in `android/app/`
- [ ] Run `flutterfire configure` OR manually update `firebase_options.dart`
- [ ] Create backend database tables
- [ ] Create backend PHP files (`save_fcm_token.php`, `FCMService.php`)
- [ ] Add Firebase Server Key to backend
- [ ] Run app: `flutter run`
- [ ] Test login and check for FCM token in logs
- [ ] Verify token saved in database
- [ ] Send test notification from backend
- [ ] Verify notification received on device

## Next Development Steps

After Firebase is working:

1. **Implement Notification Triggers**
   - Trigger notifications when new complaints are assigned
   - Trigger notifications when complaint status changes
   - Trigger notifications for priority changes

2. **Add In-App Notification Center**
   - Display notification history
   - Mark notifications as read
   - Navigate to complaint from notification

3. **Add Notification Settings**
   - Let users customize notification preferences
   - Enable/disable specific notification types

## Support & Resources

- 📚 Full Documentation: `DOCUMENTATION.md`
- 🔥 Firebase Documentation: https://firebase.google.com/docs/cloud-messaging
- 📱 Flutter Firebase: https://firebase.flutter.dev
- 💬 FlutterFire CLI: https://firebase.flutter.dev/docs/cli

## Important Notes

⚠️ **Before Running:**
- You MUST add `google-services.json` before running on Android
- You MUST configure `firebase_options.dart` with actual values
- Backend API endpoint must be ready to receive FCM tokens

⚠️ **Security:**
- Never commit `google-services.json` to public repositories
- Never expose Firebase Server Key in client code
- Use environment variables for sensitive keys

⚠️ **Testing:**
- Test on physical Android device (emulator may not support FCM)
- Check Android version (Android 13+ requires runtime notification permission)
- Verify backend is accessible from the app

---

**Ready to proceed?** Start with Step 1 and work through each step carefully. Good luck! 🚀
