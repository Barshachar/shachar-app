/// Formatters & Helpers
/// Enterprise-grade formatting utilities
library;

import 'package:intl/intl.dart';

/// Date formatters
class DateFormatters {
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _shortDateFormat = DateFormat('dd MMM yyyy');
  static final _longDateFormat = DateFormat('EEEE, dd MMMM yyyy');
  static final _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// Format date (dd/MM/yyyy)
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Format time (HH:mm)
  static String formatTime(DateTime date) => _timeFormat.format(date);

  /// Format date and time
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Format short date (dd MMM yyyy)
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);

  /// Format long date (Monday, 01 January 2024)
  static String formatLongDate(DateTime date) => _longDateFormat.format(date);

  /// Format ISO date
  static String formatISO(DateTime date) => _isoFormat.format(date);

  /// Format relative time (2 hours ago, yesterday, etc.)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'לפני כמה שניות';
    } else if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes;
      return 'לפני $minutes ${minutes == 1 ? "דקה" : "דקות"}';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      return 'לפני $hours ${hours == 1 ? "שעה" : "שעות"}';
    } else if (diff.inDays < 7) {
      final days = diff.inDays;
      return 'לפני $days ${days == 1 ? "יום" : "ימים"}';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return 'לפני $weeks ${weeks == 1 ? "שבוע" : "שבועות"}';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return 'לפני $months ${months == 1 ? "חודש" : "חודשים"}';
    } else {
      final years = (diff.inDays / 365).floor();
      return 'לפני $years ${years == 1 ? "שנה" : "שנים"}';
    }
  }

  /// Parse date from string
  static DateTime? parseDate(String date) {
    try {
      return _dateFormat.parse(date);
    } catch (e) {
      return null;
    }
  }

  /// Parse ISO date
  static DateTime? parseISO(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
}

/// Currency formatters
class CurrencyFormatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'he_IL',
    symbol: '₪',
    decimalDigits: 2,
  );

  static final _compactFormat = NumberFormat.compact(locale: 'he_IL');

  /// Format currency with symbol (₪1,234.56)
  static String formatCurrency(num amount) {
    return _currencyFormat.format(amount);
  }

  /// Format currency without symbol (1,234.56)
  static String formatAmount(num amount) {
    return NumberFormat('#,##0.00', 'he_IL').format(amount);
  }

  /// Format compact currency (₪1.2K)
  static String formatCompact(num amount) {
    return '${_compactFormat.format(amount)}₪';
  }

  /// Parse currency string to number
  static double? parseCurrency(String text) {
    try {
      final cleaned = text.replaceAll(RegExp(r'[^\d.]'), '');
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }
}

/// Number formatters
class NumberFormatters {
  /// Format number with commas (1,234,567)
  static String formatNumber(num number) {
    return NumberFormat('#,##0', 'he_IL').format(number);
  }

  /// Format decimal (1,234.56)
  static String formatDecimal(num number, {int decimals = 2}) {
    final pattern = '#,##0.${'0' * decimals}';
    return NumberFormat(pattern, 'he_IL').format(number);
  }

  /// Format percentage (12.34%)
  static String formatPercentage(num value, {int decimals = 2}) {
    return NumberFormat.percentPattern('he_IL').format(value / 100);
  }

  /// Format compact number (1.2M)
  static String formatCompact(num number) {
    return NumberFormat.compact(locale: 'he_IL').format(number);
  }

  /// Format file size (1.23 MB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Format duration (2h 30m)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// Phone formatters
class PhoneFormatters {
  /// Format Israeli phone (050-1234567 → 050-123-4567)
  static String formatIsraeliPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 9) {
      return '${cleaned.substring(0, 2)}-${cleaned.substring(2, 5)}-${cleaned.substring(5)}';
    }

    return phone;
  }

  /// Format international phone
  static String formatInternational(String phone, String countryCode) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return '+$countryCode $cleaned';
  }

  /// Validate Israeli phone
  static bool isValidIsraeliPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return cleaned.length == 9 || cleaned.length == 10;
  }
}

/// Text formatters
class TextFormatters {
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Title case
  static String titleCase(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength,
      {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  /// Remove extra whitespace
  static String cleanWhitespace(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Mask sensitive data (credit card, etc.)
  static String mask(String text, {int visibleStart = 0, int visibleEnd = 4}) {
    if (text.length <= visibleStart + visibleEnd) return text;

    final start = text.substring(0, visibleStart);
    final end = text.substring(text.length - visibleEnd);
    final masked = '*' * (text.length - visibleStart - visibleEnd);

    return '$start$masked$end';
  }
}

/// ID formatters (Israeli ID, Tax ID, etc.)
class IDFormatters {
  /// Format Israeli ID (123456789 → 12-345678-9)
  static String formatIsraeliID(String id) {
    final cleaned = id.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 9) {
      return '${cleaned.substring(0, 2)}-${cleaned.substring(2, 8)}-${cleaned.substring(8)}';
    }
    return id;
  }

  /// Validate Israeli ID with checksum
  static bool validateIsraeliID(String id) {
    final cleaned = id.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 9) return false;

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(cleaned[i]);
      int step = (i % 2) + 1;
      int result = digit * step;
      if (result > 9) result -= 9;
      sum += result;
    }

    return sum % 10 == 0;
  }

  /// Format credit card (1234567890123456 → 1234 5678 9012 3456)
  static String formatCreditCard(String number) {
    final cleaned = number.replaceAll(RegExp(r'\D'), '');
    final parts = <String>[];

    for (int i = 0; i < cleaned.length; i += 4) {
      final end = (i + 4 < cleaned.length) ? i + 4 : cleaned.length;
      parts.add(cleaned.substring(i, end));
    }

    return parts.join(' ');
  }
}

/// Address formatters
class AddressFormatters {
  /// Format full address
  static String formatAddress({
    required String street,
    required String city,
    String? zipCode,
    String? country,
  }) {
    final parts = <String>[street, city];
    if (zipCode != null) parts.add(zipCode);
    if (country != null) parts.add(country);
    return parts.join(', ');
  }

  /// Format short address
  static String formatShortAddress(String street, String city) {
    return '$street, $city';
  }
}
