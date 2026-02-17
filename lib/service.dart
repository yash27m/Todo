import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

class AuthService {
  static const String boxName = 'authBox';

  /// Hash MPIN using SHA-256
  static String _hashMpin(String mpin) {
    return sha256.convert(utf8.encode(mpin)).toString();
  }

  /// SIGN UP
  static Future<void> signup({
    required String email,
    required String mpin,
  }) async {
    final Box box = Hive.box(boxName);
    await box.put(email, _hashMpin(mpin));
  }

  /// LOGIN
  static bool login({
    required String email,
    required String mpin,
  }) {
    final Box box = Hive.box(boxName);
    final String? storedHash = box.get(email);

    if (storedHash == null) return false;
    return storedHash == _hashMpin(mpin);
  }

  /// CHECK USER EXISTS
  static bool userExists(String email) {
    final Box box = Hive.box(boxName);
    return box.containsKey(email);
  }
}

