# Firebase Admin SDK Setup - Quick Start Guide

This guide shows you how to set up Firebase Cloud Messaging using the **modern Firebase Admin SDK** instead of the deprecated legacy FCM HTTP API.

## Why Firebase Admin SDK?

✅ **Modern and Supported** - Actively maintained by Google
✅ **Better Features** - Multicast, topics, improved error handling
✅ **More Secure** - Uses service account credentials instead of server keys
✅ **Auto Cleanup** - Automatically handles invalid token cleanup
✅ **Future Proof** - Legacy API is deprecated

## Quick Setup (5 Steps)

### Step 1: Get Firebase Service Account Credentials

1. Go to https://console.firebase.google.com
2. Select your project (or create one)
3. Click ⚙️ (Settings) → **Project settings**
4. Go to **Service accounts** tab
5. Click **"Generate new private key"**
6. Download the JSON file

**IMPORTANT:** Keep this file secure! Never commit it to git.

### Step 2: Install Composer

**Already have Composer?** Skip to Step 3.

**Windows:**
- Download from: https://getcomposer.org/download/
- Run the installer

**Linux/Mac:**
```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### Step 3: Install PHP Dependencies

```bash
cd backend
composer install
```

This installs the `kreait/firebase-php` package.

### Step 4: Configure Service Account

**Option A: For Development (Simple)**

Place your downloaded JSON file here:
```
backend/config/firebase-service-account.json
```

**Option B: For Production (Secure)**

1. Store the JSON file in a secure location **outside** your web root:
   ```
   /var/secure/firebase-service-account.json
   ```

2. Set environment variable:
   ```bash
   export FIREBASE_SERVICE_ACCOUNT_PATH="/var/secure/firebase-service-account.json"
   ```

3. For Apache, add to `.htaccess` or VirtualHost config:
   ```apache
   SetEnv FIREBASE_SERVICE_ACCOUNT_PATH "/var/secure/firebase-service-account.json"
   ```

4. For nginx, add to your PHP-FPM pool config:
   ```nginx
   env[FIREBASE_SERVICE_ACCOUNT_PATH] = /var/secure/firebase-service-account.json
   ```

### Step 5: Update .gitignore

Add these lines to your `.gitignore`:
```
backend/vendor/
backend/config/firebase-service-account.json
```

## Usage

### Basic Example

```php
<?php
require_once 'vendor/autoload.php';
require_once 'services/FCMService.php';

use ServiceApp\FCMService;

$fcmService = new FCMService();

// Send notification to a user
$result = $fcmService->sendToUser(
    $userId,                    // User ID
    "New Complaint Assigned",   // Title
    "Job #12345 assigned to you", // Body
    [                           // Data payload
        'complaint_id' => 123,
        'job_id' => '12345',
        'type' => 'new_assignment'
    ]
);

if ($result['success']) {
    echo "Notification sent!";
    echo "Sent to: {$result['success_count']} devices";
} else {
    echo "Error: {$result['message']}";
}
?>
```

### In Your API Endpoints

**Example: After assigning a complaint**

```php
// In api/assign_complaint.php
require_once '../vendor/autoload.php';
require_once '../services/FCMService.php';

use ServiceApp\FCMService;

// ... your complaint assignment logic ...

// Send notification
try {
    $fcmService = new FCMService();

    $result = $fcmService->sendToUser(
        $staffUserId,
        "New Complaint Assigned",
        "Job #{$jobId} from {$customerName}",
        [
            'complaint_id' => $complaintId,
            'job_id' => $jobId,
            'type' => 'new_assignment'
        ]
    );

    // Log if successful
    if ($result['success']) {
        $fcmService->logNotification(
            $staffUserId,
            $complaintId,
            'new_assignment',
            "New Complaint Assigned",
            "Job #{$jobId} from {$customerName}",
            ['complaint_id' => $complaintId]
        );
    }
} catch (Exception $e) {
    error_log("Notification error: " . $e->getMessage());
}
```

## Advanced Usage

### Send to Multiple Users (Multicast)

More efficient than sending individually:

```php
$tokens = ['token1', 'token2', 'token3'];

$result = $fcmService->sendMulticast(
    $tokens,
    "Urgent Alert",
    "High priority complaint requires attention",
    ['priority' => 'high']
);

echo "Success: {$result['success_count']}, Failed: {$result['failure_count']}";
```

### Topic-Based Messaging

Subscribe users to topics and broadcast to all:

```php
// Subscribe users to topic
$tokens = ['token1', 'token2'];
$fcmService->subscribeToTopic($tokens, 'urgent_staff');

// Send to all subscribed users
$fcmService->sendToTopic(
    'urgent_staff',
    'Emergency Alert',
    'All hands on deck!',
    ['type' => 'emergency']
);
```

## Troubleshooting

### "Service account file not found"

**Solution:**
- Check the file path
- Ensure file has correct permissions (readable by web server)
- Verify environment variable is set correctly

**Test the path:**
```php
<?php
$path = getenv('FIREBASE_SERVICE_ACCOUNT_PATH') ?: __DIR__ . '/config/firebase-service-account.json';
echo "Looking for: " . $path . "\n";
echo "Exists: " . (file_exists($path) ? "YES" : "NO") . "\n";
echo "Readable: " . (is_readable($path) ? "YES" : "NO") . "\n";
?>
```

### "Authentication failed"

**Solutions:**
1. Verify JSON file is valid (open it, check it's proper JSON)
2. Ensure Cloud Messaging API is enabled:
   - Go to Firebase Console
   - APIs & Services → Enable APIs
   - Search for "Firebase Cloud Messaging API"
   - Enable it
3. Check service account has correct permissions

### "No FCM tokens found"

**Solution:**
- Ensure users have logged in to the app
- Check `user_fcm_tokens` table has entries
- Verify Flutter app is saving tokens correctly

### Notifications not received

**Checklist:**
1. ✅ Token saved in database
2. ✅ `is_active = 1` in database
3. ✅ User has granted notification permissions
4. ✅ App is not in battery optimization (Android)
5. ✅ Cloud Messaging API enabled in Firebase Console
6. ✅ Service account has correct permissions

## Migration from Legacy API

If you were using the old approach with `FIREBASE_SERVER_KEY`, you need to:

1. ✅ Install Composer dependencies (kreait/firebase-php)
2. ✅ Get service account JSON (not server key)
3. ✅ Update code to use new FCMService class
4. ✅ Remove old server key references
5. ✅ Test thoroughly

**No database changes needed** - The `user_fcm_tokens` table structure remains the same!

## What You DON'T Need Anymore

❌ `FIREBASE_SERVER_KEY` - Not needed with Admin SDK
❌ Manual cURL requests - Handled by SDK
❌ Manual token cleanup - Automatic in new implementation
❌ Legacy HTTP API endpoint - Using modern SDK

## Complete Example Files

All complete working examples are in:

- **`backend/README.md`** - Detailed setup guide
- **`backend/services/FCMService.php`** - Main service class
- **`backend/api/notification_examples.php`** - 9+ complete examples

## Security Checklist

- [ ] Service account JSON not in web root
- [ ] Service account JSON not committed to git
- [ ] Using environment variable in production
- [ ] File permissions restrict access
- [ ] Validate user authentication before sending
- [ ] Don't send sensitive data in notification body
- [ ] Rate limiting implemented

## Support & Resources

- **Firebase Admin PHP SDK:** https://firebase-php.readthedocs.io/
- **Firebase Console:** https://console.firebase.google.com
- **FCM Documentation:** https://firebase.google.com/docs/cloud-messaging
- **Composer:** https://getcomposer.org

## Need Help?

1. Check `backend/README.md` for detailed documentation
2. Review examples in `backend/api/notification_examples.php`
3. Enable PHP error logging to see detailed errors
4. Check Firebase Console for delivery statistics
5. Review `notification_logs` table in database

---

**Ready to send notifications?** Start with the basic example above!
