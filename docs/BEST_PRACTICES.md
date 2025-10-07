# Enterprise Flutter Best Practices

## 🎯 Overview

This document outlines best practices for using the enterprise-grade features in this application.

---

## 1. Design System

### Using Components

```dart
// ✅ Good - Use design system components
AppButton.primary(
  text: 'Submit',
  onPressed: handleSubmit,
)

// ❌ Bad - Don't create custom buttons
ElevatedButton(
  child: Text('Submit'),
  onPressed: handleSubmit,
)
```

### Using Design Tokens

```dart
// ✅ Good - Use design tokens
Container(
  padding: Insets.all4,
  decoration: BoxDecoration(
    color: SemanticColors.primary,
    borderRadius: BorderRadii.md,
  ),
)

// ❌ Bad - Don't use magic numbers
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFF0066CC),
    borderRadius: BorderRadius.circular(8),
  ),
)
```

---

## 2. Security

### 2FA Implementation

```dart
// Generate secret for new user
final secret = TOTPService.generateSecret();

// Store secret securely
await secureStorage.write(key: 'totp_secret', value: secret);

// Verify user code
final isValid = TOTPService.verifyTOTP(
  secret: secret,
  code: userEnteredCode,
);
```

### Session Management

```dart
// Initialize session after login
final sessionManager = SessionManager();
await sessionManager.initializeSession(
  sessionId: response.sessionId,
  userId: user.id,
  deviceId: deviceInfo.deviceId,
  deviceName: deviceInfo.deviceName,
  ipAddress: request.ipAddress,
);

// Update activity on user actions
sessionManager.updateActivity();

// End session on logout
await sessionManager.endSession();
```

### Rate Limiting

```dart
// Apply rate limit to sensitive operations
final result = globalRateLimiter.checkLimit(
  key: 'user:${user.id}:login',
  maxRequests: 5,
  window: Duration(minutes: 15),
);

if (!result.allowed) {
  throw RateLimitException(
    'Too many login attempts. Try again in ${result.retryAfter.inMinutes} minutes.',
    result,
  );
}
```

---

## 3. Error Handling

### Error Tracking

```dart
// Initialize in main
await errorTracking.initialize(
  dsn: 'YOUR_SENTRY_DSN',
  environment: 'production',
);

// Set user context
errorTracking.setUser(
  userId: user.id,
  email: user.email,
  username: user.name,
);

// Add breadcrumbs
errorTracking.addBreadcrumb(
  message: 'User navigated to checkout',
  category: 'navigation',
);

// Capture exceptions
try {
  await riskyOperation();
} catch (e, stackTrace) {
  errorTracking.captureException(
    e,
    stackTrace: stackTrace,
    severity: ErrorSeverity.error,
  );
  rethrow;
}
```

### Error Boundaries

```dart
// Wrap widgets with error boundary
ErrorBoundary(
  child: MyWidget(),
  onError: (error, stackTrace) {
    errorTracking.captureException(error, stackTrace: stackTrace);
  },
  errorBuilder: (error, stackTrace) {
    return ErrorState(
      title: 'Something went wrong',
      onRetry: () => setState(() {}),
    );
  },
)
```

---

## 4. Performance

### Caching

```dart
// Use cache for expensive operations
final data = await cachedAsync(
  key: 'user:${userId}:profile',
  compute: () => api.fetchUserProfile(userId),
  ttl: Duration(minutes: 5),
);

// Clear cache when data changes
memoryCache.getCache('default').remove('user:${userId}:profile');
```

### Network Retry

```dart
// Retry failed requests
final data = await withRetry(
  action: () => api.fetchData(),
  policy: RetryPolicy.aggressive,
  onRetry: (attempt, error) {
    print('Retry attempt $attempt: $error');
  },
);
```

### Debouncing

```dart
// Debounce search input
final debouncer = Debouncer(delay: Duration(milliseconds: 500));

TextField(
  onChanged: (value) {
    debouncer(() {
      searchProducts(value);
    });
  },
)
```

---

## 5. Validation

### Form Validation

```dart
final emailValidator = EmailValidator.validate(email);
if (!emailValidator.isValid) {
  return emailValidator.error;
}

final passwordValidator = PasswordValidator.validate(
  password,
  minLength: 12,
  requireUppercase: true,
  requireDigit: true,
  requireSpecialChar: true,
);

if (!passwordValidator.isValid) {
  return passwordValidator.error;
}
```

### Israeli-specific Validation

```dart
// Validate Israeli ID
final idValidator = IsraeliIDValidator.validate(idNumber);
if (!idValidator.isValid) {
  return idValidator.error; // Will check checksum
}

// Validate Israeli phone
final phoneValidator = PhoneValidator.validateIsraeli(phone);
if (!phoneValidator.isValid) {
  return phoneValidator.error;
}
```

---

## 6. Formatting

### Currency

```dart
// Format Israeli currency
final formatted = CurrencyFormatters.formatCurrency(1234.56);
// Output: ₪1,234.56
```

### Dates

```dart
// Format date
final date = DateFormatters.formatDate(DateTime.now());
// Output: 01/10/2025

// Format relative time
final relative = DateFormatters.formatRelative(DateTime.now().subtract(Duration(hours: 2)));
// Output: לפני 2 שעות
```

---

## 7. Analytics

### Tracking Events

```dart
// Initialize
await analytics.initialize(apiKey: 'YOUR_KEY');

// Set user
analytics.setUserId(user.id);
analytics.setUserProperties({
  'plan': 'premium',
  'signup_date': user.createdAt.toIso8601String(),
});

// Track events
analytics.trackScreenView('ProductDetails');
analytics.trackAction('add_to_cart', parameters: {
  'product_id': product.id,
  'quantity': quantity,
});

// Track purchases
analytics.trackPurchase(
  transactionId: order.id,
  value: order.total,
  currency: 'ILS',
  items: order.items.map((item) => item.toJson()).toList(),
);
```

---

## 8. State Management

### Using Providers

```dart
// ✅ Good - Proper provider usage
final user = context.watch<UserProvider>().currentUser;

// ❌ Bad - Don't use listen: false unnecessarily
final user = Provider.of<UserProvider>(context, listen: false).currentUser;
```

---

## 9. Testing

### Unit Tests

```dart
test('should validate Israeli ID correctly', () {
  expect(IsraeliIDValidator.isValid('123456782'), true);
  expect(IsraeliIDValidator.isValid('123456789'), false);
});
```

### Widget Tests

```dart
testWidgets('button should show loading state', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AppButton.primary(
        text: 'Submit',
        isLoading: true,
        onPressed: () {},
      ),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

---

## 10. Code Organization

### File Structure

```
lib/
├── src/
│   ├── design_system/    # Design tokens & components
│   ├── features/          # Feature modules
│   ├── security/          # Security utilities
│   ├── monitoring/        # Analytics & error tracking
│   ├── performance/       # Performance utilities
│   └── utils/             # Shared utilities
```

### Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables: `camelCase`
- Constants: `camelCase` or `SCREAMING_SNAKE_CASE`
- Private: `_leadingUnderscore`

---

## 11. Accessibility

### Screen Reader Support

```dart
// Add semantics labels
Semantics(
  label: 'Submit order button',
  button: true,
  child: AppButton.primary(
    text: 'Submit',
    onPressed: handleSubmit,
  ),
)
```

### RTL Support

All components support RTL automatically. Use `Directionality` widget:

```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: MyApp(),
)
```

---

## 12. GDPR Compliance

### User Data Export

```dart
final userData = await getUserData(userId);
final export = GDPRService.generateUserDataExport(userData);
await sendToUser(export);
```

### Data Anonymization

```dart
final anonymizedEmail = GDPRService.anonymizeEmail(user.email);
final anonymizedPhone = GDPRService.anonymizePhone(user.phone);
```

---

## Summary

✅ **DO**:
- Use design system components
- Implement proper error handling
- Add analytics tracking
- Validate user input
- Cache expensive operations
- Follow security best practices

❌ **DON'T**:
- Create custom components instead of using design system
- Use magic numbers for spacing/colors
- Ignore error handling
- Skip input validation
- Make unnecessary API calls
- Store sensitive data unencrypted

---

For more information, see:
- [API Documentation](./API.md)
- [Architecture Decisions](./ADRs/)
- [Integration Guide](./INTEGRATION_GUIDE.md)
