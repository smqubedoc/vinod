import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/complaint.dart';
import '../utils/constants.dart';

class ApiService {
  // Login
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.loginEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Save user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(data['user']));
          await prefs.setString('token', data['user']['token']);

          return {'success': true, 'user': User.fromJson(data['user'])};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed'
          };
        }
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get Complaints
  static Future<Map<String, dynamic>> getComplaints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userJson = prefs.getString('user') ?? '';

      if (token.isEmpty || userJson.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final user = json.decode(userJson);

      final response = await http.post(
        Uri.parse(Constants.complaintsEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: {
          'user_id': user['user_id'].toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<Complaint> complaints = (data['complaints'] as List)
              .map((json) => Complaint.fromJson(json))
              .toList();
          return {'success': true, 'complaints': complaints};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to load complaints'
          };
        }
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Update Complaint
  static Future<Map<String, dynamic>> updateComplaint({
    required int complaintId,
    required String status,
    required String notes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse(Constants.updateComplaintEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: {
          'complaint_id': complaintId.toString(),
          'status': status,
          'notes': notes,
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

      // Determine device type
      String deviceType = 'web';
      try {
        if (Platform.isAndroid) {
          deviceType = 'android';
        } else if (Platform.isIOS) {
          deviceType = 'ios';
        }
      } catch (e) {
        deviceType = 'web';
      }

      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/save_fcm_token.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: {
          'user_id': user['user_id'].toString(),
          'fcm_token': fcmToken,
          'device_type': deviceType,
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

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }
}
