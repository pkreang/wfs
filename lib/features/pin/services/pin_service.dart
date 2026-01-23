import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:wfs/models/user_model.dart';

class PinService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _pinKey = 'user_pin_hash';
  static const String _userKey = 'user_data';

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null;
  }

  Future<void> savePinStorage(String pin) async {
    final hashedPin = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hashedPin);
  }

  bool verifyPin(String pin) {
    // For synchronous operation, we need to handle async internally
    // This is a workaround - in production use verifyPinAsync directly
    final hashedPin = _hashPin(pin);
    // This will need to be refactored to be fully async
    return true; // Placeholder
  }

  Future<bool> verifyPinAsync(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;

    final inputHash = _hashPin(pin);
    return storedHash == inputHash;
  }

  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
  }

  // Save User model to secure storage
  Future<void> saveUser(User user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _storage.write(key: _userKey, value: userJson);
      print('User saved to secure storage');
    } catch (e) {
      print('Error saving user to secure storage: $e');
    }
  }

  // Get User model from secure storage
  Future<User?> getUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson == null) return null;

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      print('Error getting user from secure storage: $e');
      return null;
    }
  }

  // Remove User from secure storage
  Future<void> removeUser() async {
    await _storage.delete(key: _userKey);
  }

  // Clear all data (PIN + User)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
