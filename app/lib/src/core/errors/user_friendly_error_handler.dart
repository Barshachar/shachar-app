/// User-friendly error handler service
/// Converts technical errors to user-friendly Hebrew messages
library;

import 'package:flutter/foundation.dart';

/// Maps error types to user-friendly messages
class UserFriendlyErrorHandler {
  /// Convert any error to a user-friendly message in Hebrew
  static String getErrorMessage(Object error, {StackTrace? stackTrace}) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('failed to connect')) {
      return 'לא הצלחנו להתחבר לשרת. אנא בדוק את החיבור לאינטרנט ונסה שוב.';
    }

    // Timeout errors
    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'הפעולה לקחה יותר מדי זמן. אנא נסה שוב.';
    }

    // Authentication errors
    if (errorString.contains('unauthorized') ||
        errorString.contains('authentication') ||
        errorString.contains('invalid credentials')) {
      return 'שם משתמש או סיסמה שגויים. אנא נסה שוב.';
    }

    // Permission errors
    if (errorString.contains('permission') ||
        errorString.contains('forbidden') ||
        errorString.contains('access denied')) {
      return 'אין לך הרשאה לבצע פעולה זו.';
    }

    // Not found errors
    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'המידע המבוקש לא נמצא.';
    }

    // Server errors
    if (errorString.contains('server error') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return 'אירעה שגיאה בשרת. אנא נסה שוב מאוחר יותר.';
    }

    // Validation errors
    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return 'אנא בדוק את הנתונים שהזנת ונסה שוב.';
    }

    // Database errors
    if (errorString.contains('database') || errorString.contains('query')) {
      return 'אירעה שגיאה בשמירת הנתונים. אנא נסה שוב.';
    }

    // File errors
    if (errorString.contains('file') || errorString.contains('upload')) {
      return 'אירעה שגיאה בהעלאת הקובץ. אנא ודא שהקובץ תקין ונסה שוב.';
    }

    // Payment errors
    if (errorString.contains('payment') || errorString.contains('card')) {
      return 'אירעה שגיאה בעיבוד התשלום. אנא בדוק את פרטי התשלום ונסה שוב.';
    }

    // Inventory errors
    if (errorString.contains('stock') ||
        errorString.contains('inventory') ||
        errorString.contains('out of stock')) {
      return 'מוצר זה אזל מהמלאי. אנא בחר מוצר אחר.';
    }

    // Rate limit errors
    if (errorString.contains('too many requests') ||
        errorString.contains('rate limit')) {
      return 'ביצעת יותר מדי פעולות. אנא המתן מספר דקות ונסה שוב.';
    }

    // Generic fallback
    debugPrint('[Error Handler] Unknown error: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrintStack(stackTrace: stackTrace, label: 'Error Stack');
    }

    return 'אירעה שגיאה בלתי צפויה. אנא נסה שוב או פנה לתמיכה.';
  }

  /// Get a title for the error (optional, for toast notifications)
  static String getErrorTitle(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'בעיית תקשורת';
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('authentication')) {
      return 'שגיאת התחברות';
    }

    if (errorString.contains('permission') ||
        errorString.contains('forbidden')) {
      return 'אין הרשאה';
    }

    if (errorString.contains('not found')) {
      return 'לא נמצא';
    }

    if (errorString.contains('server')) {
      return 'שגיאת שרת';
    }

    if (errorString.contains('validation')) {
      return 'שגיאת קלט';
    }

    return 'שגיאה';
  }

  /// Check if error is recoverable (user can try again)
  static bool isRecoverable(Object error) {
    final errorString = error.toString().toLowerCase();

    // Non-recoverable errors
    if (errorString.contains('permission') ||
        errorString.contains('forbidden') ||
        errorString.contains('unauthorized')) {
      return false;
    }

    // Most errors are recoverable
    return true;
  }

  /// Get suggested action for the error
  static String? getSuggestedAction(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'בדוק את החיבור לאינטרנט';
    }

    if (errorString.contains('timeout')) {
      return 'נסה שוב';
    }

    if (errorString.contains('validation')) {
      return 'בדוק את הנתונים';
    }

    if (errorString.contains('rate limit')) {
      return 'המתן מספר דקות';
    }

    return null;
  }
}

/// Extension for easier error handling
extension ErrorHandlerExtension on Object {
  /// Get user-friendly message
  String get userFriendlyMessage =>
      UserFriendlyErrorHandler.getErrorMessage(this);

  /// Get error title
  String get errorTitle => UserFriendlyErrorHandler.getErrorTitle(this);

  /// Check if recoverable
  bool get isRecoverable => UserFriendlyErrorHandler.isRecoverable(this);

  /// Get suggested action
  String? get suggestedAction =>
      UserFriendlyErrorHandler.getSuggestedAction(this);
}
