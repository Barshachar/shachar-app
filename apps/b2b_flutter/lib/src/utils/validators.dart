/// Validators
/// Enterprise-grade validation utilities
library;

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult.valid()
      : isValid = true,
        error = null;
  const ValidationResult.invalid(this.error) : isValid = false;

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $error';
}

/// Email validator
class EmailValidator {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static ValidationResult validate(String email) {
    if (email.isEmpty) {
      return const ValidationResult.invalid('אימייל חובה');
    }

    if (!_emailRegex.hasMatch(email)) {
      return const ValidationResult.invalid('כתובת אימייל לא תקינה');
    }

    return const ValidationResult.valid();
  }

  static bool isValid(String email) => validate(email).isValid;
}

/// Password validator
class PasswordValidator {
  static ValidationResult validate(
    String password, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecialChar = true,
  }) {
    if (password.isEmpty) {
      return const ValidationResult.invalid('סיסמה חובה');
    }

    if (password.length < minLength) {
      return ValidationResult.invalid(
          'סיסמה חייבת להכיל לפחות $minLength תווים');
    }

    if (requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      return const ValidationResult.invalid('סיסמה חייבת להכיל אות גדולה');
    }

    if (requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
      return const ValidationResult.invalid('סיסמה חייבת להכיל אות קטנה');
    }

    if (requireDigit && !password.contains(RegExp(r'[0-9]'))) {
      return const ValidationResult.invalid('סיסמה חייבת להכיל ספרה');
    }

    if (requireSpecialChar &&
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return const ValidationResult.invalid('סיסמה חייבת להכיל תו מיוחד');
    }

    return const ValidationResult.valid();
  }

  static bool isValid(String password) => validate(password).isValid;

  /// Calculate password strength (0-100)
  static int calculateStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength += 20;
    if (password.length >= 12) strength += 10;
    if (password.length >= 16) strength += 10;

    if (password.contains(RegExp(r'[A-Z]'))) strength += 15;
    if (password.contains(RegExp(r'[a-z]'))) strength += 15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 15;

    return strength.clamp(0, 100);
  }
}

/// Phone validator
class PhoneValidator {
  static ValidationResult validateIsraeli(String phone) {
    if (phone.isEmpty) {
      return const ValidationResult.invalid('מספר טלפון חובה');
    }

    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length != 9 && cleaned.length != 10) {
      return const ValidationResult.invalid('מספר טלפון לא תקין');
    }

    // Israeli mobile prefixes
    if (cleaned.length == 10) {
      final prefix = cleaned.substring(0, 3);
      final validPrefixes = ['050', '051', '052', '053', '054', '055', '058'];
      if (!validPrefixes.contains(prefix)) {
        return const ValidationResult.invalid('קידומת לא תקינה');
      }
    }

    return const ValidationResult.valid();
  }

  static bool isValidIsraeli(String phone) => validateIsraeli(phone).isValid;
}

/// Israeli ID validator
class IsraeliIDValidator {
  static ValidationResult validate(String id) {
    if (id.isEmpty) {
      return const ValidationResult.invalid('תעודת זהות חובה');
    }

    final cleaned = id.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length != 9) {
      return const ValidationResult.invalid('תעודת זהות חייבת להכיל 9 ספרות');
    }

    // Validate checksum
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(cleaned[i]);
      int step = (i % 2) + 1;
      int result = digit * step;
      if (result > 9) result -= 9;
      sum += result;
    }

    if (sum % 10 != 0) {
      return const ValidationResult.invalid('מספר תעודת זהות לא תקין');
    }

    return const ValidationResult.valid();
  }

  static bool isValid(String id) => validate(id).isValid;
}

/// Credit card validator
class CreditCardValidator {
  static ValidationResult validate(String cardNumber) {
    if (cardNumber.isEmpty) {
      return const ValidationResult.invalid('מספר כרטיס חובה');
    }

    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length < 13 || cleaned.length > 19) {
      return const ValidationResult.invalid('מספר כרטיס לא תקין');
    }

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;

    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      alternate = !alternate;
    }

    if (sum % 10 != 0) {
      return const ValidationResult.invalid('מספר כרטיס לא תקין');
    }

    return const ValidationResult.valid();
  }

  static bool isValid(String cardNumber) => validate(cardNumber).isValid;

  /// Get card type
  static String? getCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleaned.startsWith(RegExp(r'^4'))) return 'Visa';
    if (cleaned.startsWith(RegExp(r'^5[1-5]'))) return 'Mastercard';
    if (cleaned.startsWith(RegExp(r'^3[47]'))) return 'Amex';
    if (cleaned.startsWith(RegExp(r'^6(?:011|5)'))) return 'Discover';

    return null;
  }
}

/// URL validator
class URLValidator {
  static final _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  static ValidationResult validate(String url) {
    if (url.isEmpty) {
      return const ValidationResult.invalid('כתובת URL חובה');
    }

    if (!_urlRegex.hasMatch(url)) {
      return const ValidationResult.invalid('כתובת URL לא תקינה');
    }

    return const ValidationResult.valid();
  }

  static bool isValid(String url) => validate(url).isValid;
}

/// Number validator
class NumberValidator {
  static ValidationResult validate(
    String value, {
    num? min,
    num? max,
  }) {
    if (value.isEmpty) {
      return const ValidationResult.invalid('ערך חובה');
    }

    final number = num.tryParse(value);
    if (number == null) {
      return const ValidationResult.invalid('ערך חייב להיות מספר');
    }

    if (min != null && number < min) {
      return ValidationResult.invalid('ערך חייב להיות לפחות $min');
    }

    if (max != null && number > max) {
      return ValidationResult.invalid('ערך חייב להיות לכל היותר $max');
    }

    return const ValidationResult.valid();
  }

  static bool isValid(String value) => validate(value).isValid;
}

/// String validator
class StringValidator {
  static ValidationResult validate(
    String value, {
    int? minLength,
    int? maxLength,
    RegExp? pattern,
    String? patternError,
  }) {
    if (value.isEmpty) {
      return const ValidationResult.invalid('שדה חובה');
    }

    if (minLength != null && value.length < minLength) {
      return ValidationResult.invalid('חייב להכיל לפחות $minLength תווים');
    }

    if (maxLength != null && value.length > maxLength) {
      return ValidationResult.invalid('חייב להכיל לכל היותר $maxLength תווים');
    }

    if (pattern != null && !pattern.hasMatch(value)) {
      return ValidationResult.invalid(patternError ?? 'פורמט לא תקין');
    }

    return const ValidationResult.valid();
  }

  static bool isValid(String value) => validate(value).isValid;
}

/// Required field validator
class RequiredValidator {
  static ValidationResult validate(dynamic value, {String? fieldName}) {
    if (value == null) {
      return ValidationResult.invalid(
        fieldName != null ? '$fieldName חובה' : 'שדה חובה',
      );
    }

    if (value is String && value.trim().isEmpty) {
      return ValidationResult.invalid(
        fieldName != null ? '$fieldName חובה' : 'שדה חובה',
      );
    }

    if (value is List && value.isEmpty) {
      return ValidationResult.invalid(
        fieldName != null ? '$fieldName חובה' : 'שדה חובה',
      );
    }

    return const ValidationResult.valid();
  }

  static bool isValid(dynamic value) => validate(value).isValid;
}

/// Composite validator
class CompositeValidator {
  final List<ValidationResult Function()> validators;

  CompositeValidator(this.validators);

  ValidationResult validate() {
    for (final validator in validators) {
      final result = validator();
      if (!result.isValid) {
        return result;
      }
    }
    return const ValidationResult.valid();
  }

  bool get isValid => validate().isValid;
}

/// Form validator
class FormValidator {
  final Map<String, List<ValidationResult Function()>> _fields = {};

  void addField(
      String fieldName, List<ValidationResult Function()> validators) {
    _fields[fieldName] = validators;
  }

  Map<String, String?> validate() {
    final errors = <String, String?>{};

    for (final entry in _fields.entries) {
      for (final validator in entry.value) {
        final result = validator();
        if (!result.isValid) {
          errors[entry.key] = result.error;
          break; // Stop at first error for this field
        }
      }
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;
}
