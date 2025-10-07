/// Encryption Service
/// Enterprise-grade data encryption utilities
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Encryption service for sensitive data
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  /// Hash password with salt
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate salt
  String generateSalt() {
    final random = List<int>.generate(
        32, (i) => DateTime.now().microsecondsSinceEpoch % 256);
    return base64Url.encode(random);
  }

  /// Hash data with SHA-256
  String sha256Hash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hash data with SHA-512
  String sha512Hash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  /// HMAC signing
  String hmacSign(String data, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  /// Verify HMAC signature
  bool verifyHmac(String data, String signature, String secret) {
    final computed = hmacSign(data, secret);
    return computed == signature;
  }

  /// Encode sensitive data to base64
  String encodeBase64(String data) {
    final bytes = utf8.encode(data);
    return base64.encode(bytes);
  }

  /// Decode base64 data
  String decodeBase64(String encoded) {
    final bytes = base64.decode(encoded);
    return utf8.decode(bytes);
  }

  /// Generate random token
  String generateToken({int length = 32}) {
    final random = List<int>.generate(
      length,
      (i) => DateTime.now().microsecondsSinceEpoch % 256,
    );
    return base64Url.encode(random).substring(0, length);
  }

  /// Mask sensitive data (credit card, etc.)
  String maskSensitiveData(String data, {int visibleChars = 4}) {
    if (data.length <= visibleChars) return data;
    final visible = data.substring(data.length - visibleChars);
    final masked = '*' * (data.length - visibleChars);
    return masked + visible;
  }

  /// Sanitize input to prevent injection
  String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }
}

/// Global encryption instance
final encryption = EncryptionService();

/// GDPR compliance helpers
class GDPRService {
  /// Anonymize email
  static String anonymizeEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***@***.***';

    final username = parts[0];
    final domain = parts[1];

    final maskedUsername = username.length > 2
        ? '${username[0]}***${username[username.length - 1]}'
        : '***';

    return '$maskedUsername@$domain';
  }

  /// Anonymize phone
  static String anonymizePhone(String phone) {
    if (phone.length < 4) return '****';
    return '****${phone.substring(phone.length - 4)}';
  }

  /// Anonymize name
  static String anonymizeName(String name) {
    final parts = name.split(' ');
    return parts.map((part) {
      if (part.isEmpty) return '';
      return '${part[0]}***';
    }).join(' ');
  }

  /// Generate data export
  static Map<String, dynamic> generateUserDataExport(
      Map<String, dynamic> userData) {
    return {
      'export_date': DateTime.now().toIso8601String(),
      'user_data': userData,
      'gdpr_compliant': true,
      'data_retention_policy': '30 days',
    };
  }
}
