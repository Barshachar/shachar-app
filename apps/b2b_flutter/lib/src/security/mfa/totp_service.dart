/// TOTP (Time-based One-Time Password) Service
/// Implements RFC 6238 for 2FA authentication
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// TOTP Service for generating and verifying time-based codes
class TOTPService {
  /// Generate a secret key for TOTP
  static String generateSecret({int length = 32}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'; // Base32 alphabet
    final random = Random.secure();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Generate TOTP code from secret
  static String generateTOTP({
    required String secret,
    int digits = 6,
    int period = 30,
    DateTime? time,
  }) {
    final counter = _getCounter(time ?? DateTime.now(), period);
    return _generateHOTP(secret, counter, digits);
  }

  /// Verify TOTP code
  static bool verifyTOTP({
    required String secret,
    required String code,
    int digits = 6,
    int period = 30,
    int window = 1, // Allow codes from adjacent time windows
  }) {
    final now = DateTime.now();
    final counter = _getCounter(now, period);

    // Check current and adjacent time windows
    for (int i = -window; i <= window; i++) {
      final testCounter = counter + i;
      final expectedCode = _generateHOTP(secret, testCounter, digits);
      if (expectedCode == code) {
        return true;
      }
    }
    return false;
  }

  /// Generate QR code URL for authenticator apps
  static String generateQRCodeUrl({
    required String secret,
    required String accountName,
    required String issuer,
  }) {
    final params = {
      'secret': secret,
      'issuer': issuer,
      'algorithm': 'SHA1',
      'digits': '6',
      'period': '30',
    };

    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'otpauth://totp/${Uri.encodeComponent(issuer)}:${Uri.encodeComponent(accountName)}?$query';
  }

  /// Get time-based counter
  static int _getCounter(DateTime time, int period) {
    return (time.millisecondsSinceEpoch ~/ 1000) ~/ period;
  }

  /// Generate HOTP (HMAC-based One-Time Password)
  static String _generateHOTP(String secret, int counter, int digits) {
    final key = _base32Decode(secret);
    final message = _intToBytes(counter);

    // HMAC-SHA1
    final hmac = Hmac(sha1, key);
    final hash = hmac.convert(message).bytes;

    // Dynamic truncation
    final offset = hash[hash.length - 1] & 0x0f;
    final binary = ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);

    // Generate code
    final code = binary % pow(10, digits).toInt();
    return code.toString().padLeft(digits, '0');
  }

  /// Convert integer to 8-byte array (big-endian)
  static Uint8List _intToBytes(int value) {
    final bytes = Uint8List(8);
    for (int i = 7; i >= 0; i--) {
      bytes[i] = value & 0xff;
      value >>= 8;
    }
    return bytes;
  }

  /// Decode Base32 string
  static Uint8List _base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final cleanInput = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');

    final output = <int>[];
    int buffer = 0;
    int bitsLeft = 0;

    for (int i = 0; i < cleanInput.length; i++) {
      final val = alphabet.indexOf(cleanInput[i]);
      if (val == -1) continue;

      buffer = (buffer << 5) | val;
      bitsLeft += 5;

      if (bitsLeft >= 8) {
        output.add((buffer >> (bitsLeft - 8)) & 0xff);
        bitsLeft -= 8;
      }
    }

    return Uint8List.fromList(output);
  }
}

/// Backup codes generator
class BackupCodesService {
  /// Generate backup codes
  static List<String> generateBackupCodes({int count = 8, int length = 8}) {
    final codes = <String>[];
    final random = Random.secure();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    for (int i = 0; i < count; i++) {
      final code = List.generate(
        length,
        (_) => chars[random.nextInt(chars.length)],
      ).join();

      // Format as XXXX-XXXX
      final formatted = '${code.substring(0, 4)}-${code.substring(4)}';
      codes.add(formatted);
    }

    return codes;
  }

  /// Hash backup code for storage
  static String hashBackupCode(String code) {
    final bytes = utf8.encode(code.toUpperCase().replaceAll('-', ''));
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify backup code
  static bool verifyBackupCode(String code, String hashedCode) {
    return hashBackupCode(code) == hashedCode;
  }
}
