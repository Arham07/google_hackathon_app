import 'package:shared_preferences/shared_preferences.dart';

/// Static demo auth — no network; persists session locally.
class AuthService {
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keyLoggedIn = 'logged_in';
  static const String _keyUserName = 'user_name';
  static const String _keyPhone = 'user_phone';
  static const String _keyEmail = 'user_email';
  static const String _keyCnic = 'user_cnic';

  /// Demo OTP — any 6-digit code is accepted; this is the suggested code.
  static const String demoOtp = '123456';

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }

  /// Simulates sending an OTP (no network).
  Future<void> sendOtp({required String phone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  /// Demo verify — accepts any 6-digit code.
  bool verifyOtp(String code) {
    final String trimmed = code.trim();
    return RegExp(r'^\d{6}$').hasMatch(trimmed);
  }

  Future<void> saveProfile({
    required String name,
    required String phone,
    String? email,
    String? cnic,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyPhone, phone);
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_keyEmail, email);
    } else {
      await prefs.remove(_keyEmail);
    }
    if (cnic != null && cnic.isNotEmpty) {
      await prefs.setString(_keyCnic, cnic);
    } else {
      await prefs.remove(_keyCnic);
    }
  }

  Future<void> login({
    required String name,
    required String phone,
    String? email,
    String? cnic,
  }) async {
    await saveProfile(
      name: name,
      phone: phone,
      email: email,
      cnic: cnic,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
  }

  /// Logs in with OTP when a profile already exists for this phone.
  Future<void> loginWithPhoneOtp({required String phone}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedPhone = prefs.getString(_keyPhone);
    if (storedPhone != phone) {
      await saveProfile(name: 'User', phone: phone);
    }
    await prefs.setBool(_keyLoggedIn, true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
  }
}
