import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.222.225:5169/api';
  static String? _deviceId;
  static User? _currentUser;

  static Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');

    if (_deviceId == null) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final info = await deviceInfo.androidInfo;
          _deviceId = info.id;
        } else if (Platform.isIOS) {
          final info = await deviceInfo.iosInfo;
          _deviceId = info.identifierForVendor ?? const Uuid().v4();
        } else {
          _deviceId = const Uuid().v4();
        }
      } catch (e) {
        _deviceId = const Uuid().v4();
      }
      await prefs.setString('device_id', _deviceId!);
    }

    print('backIntLogs: Device ID: $_deviceId');
    return _deviceId!;
  }

  static Future<User?> register(String email, String password) async {
    try {
      final deviceId = await getDeviceId();
      print('regLogin: Starting registration for: $email');
      print('regLogin: Device ID: $deviceId');

      final requestBody = {'email': email, 'password': password, 'deviceId': deviceId};
      print('regLogin: Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('regLogin: Response status: ${response.statusCode}');
      print('regLogin: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        await _saveUser(user);
        _currentUser = user;
        print('regLogin: Registration successful');
        return user;
      }
      print('regLogin: Registration failed with status ${response.statusCode}');
      return null;
    } catch (e) {
      print('regLogin: Registration exception: $e');
      return null;
    }
  }

  static Future<User?> login(String email, String password) async {
    try {
      final deviceId = await getDeviceId();
      print('regLogin: Starting login for: $email');
      print('regLogin: Device ID: $deviceId');

      final requestBody = {'email': email, 'password': password, 'deviceId': deviceId};
      print('regLogin: Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('regLogin: Response status: ${response.statusCode}');
      print('regLogin: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        await _saveUser(user);
        _currentUser = user;
        print('regLogin: Login successful');
        return user;
      }
      print('regLogin: Login failed with status ${response.statusCode}');
      return null;
    } catch (e) {
      print('regLogin: Login exception: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    _currentUser = null;
    print('backIntLogs: User logged out');
  }

  static Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    final id = prefs.getString('user_id');
    final email = prefs.getString('user_email');

    if (token != null && id != null && email != null) {
      _currentUser = User(id: id, email: email, token: token);
      return _currentUser;
    }
    return null;
  }

  static String? getToken() => _currentUser?.token;

  static Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', user.token);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
  }
}
