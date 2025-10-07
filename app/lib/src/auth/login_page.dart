import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/auth/auth_resilience.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

final loginAuthClientProvider = Provider<GoTrueClient>((ref) {
  return Supabase.instance.client.auth;
});

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const int _resilientMaxAttempts = 3;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isSendingReset = false;
  bool _useFaceId = false;

  String _homePathForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '/admin';
      case UserRole.vendorAdmin:
      case UserRole.vendorUser:
        return '/vendor';
      case UserRole.customerAdmin:
      case UserRole.buyer:
        return '/customer'; // ברירת מחדל לבייר/לקוח
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppConfig> configAsync = ref.watch(appConfigProvider);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final TextDirection textDirection = TextDirection.ltr;
    final EdgeInsetsDirectional directionalPadding = context.pagePadding();
    final EdgeInsets resolvedPadding =
        directionalPadding.resolve(textDirection);
    final Size size = MediaQuery.of(context).size;

    final String titleText = _t(l10n, 'loginTitle', 'Welcome');
    final String subtitleText = _t(
      l10n,
      'loginSubtitle',
      'Sign in to manage your marketplace operations.',
    );
    final String loginCta = _isSubmitting
        ? _t(l10n, 'loginButtonLoading', 'Signing in...')
        : _t(l10n, 'loginButton', 'Sign in');
    final String demoLabel = _t(l10n, 'loginDemoCta', 'Use demo mode');
    final String forgotPasswordLabel =
        _t(l10n, 'loginForgotPasswordCta', 'Forgot password?');
    final String faceIdLabel = _t(l10n, 'loginFaceIdToggle', 'Use Face ID');

    final Widget form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isSubmitting || _isSendingReset)
            const Padding(
              padding: EdgeInsets.only(bottom: ASpacing.sm),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          Text(
            titleText,
            textAlign: TextAlign.start,
            style: ATypography.headline1.copyWith(fontSize: 30),
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            subtitleText,
            textAlign: TextAlign.start,
            style: ATypography.bodyLg.copyWith(
              color: AColors.mutedForeground,
            ),
          ),
          const SizedBox(height: ASpacing.xl),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _errorMessage == null
                ? const SizedBox.shrink()
                : Padding(
                    key: ValueKey<String>(_errorMessage!),
                    padding: const EdgeInsets.only(bottom: ASpacing.md),
                    child: _InlineMessage(message: _errorMessage!),
                  ),
          ),
          _EmailField(
            controller: _emailController,
            l10n: l10n,
            enabled: !_isSubmitting,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: ASpacing.md),
          _PasswordField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onToggleVisibility: _togglePasswordVisibility,
            onSubmitted: (_) => _handleSubmit(),
            enabled: !_isSubmitting,
            l10n: l10n,
          ),
          const SizedBox(height: ASpacing.lg),
          AButton.primary(
            expand: true,
            label: loginCta,
            loading: _isSubmitting,
            onPressed:
                (_isSubmitting || _isSendingReset) ? null : _handleSubmit,
          ),
          const SizedBox(height: ASpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: (_isSubmitting || _isSendingReset)
                  ? null
                  : () => _handleForgotPassword(l10n: l10n),
              child: Text(forgotPasswordLabel),
            ),
          ),
          const SizedBox(height: ASpacing.lg),
          Row(
            children: [
              const Icon(
                Icons.fingerprint,
                size: 48,
                color: AColors.neutral400,
              ),
              const SizedBox(width: ASpacing.md),
              Expanded(
                child: Text(
                  faceIdLabel,
                  style: ATypography.bodyLg,
                ),
              ),
              Switch.adaptive(
                value: _useFaceId,
                onChanged: (_isSubmitting || _isSendingReset)
                    ? null
                    : (bool value) {
                        setState(() => _useFaceId = value);
                      },
                activeColor: AColors.primary,
              ),
            ],
          ),
          const SizedBox(height: ASpacing.lg),
          configAsync.maybeWhen(
            data: (config) => TextButton.icon(
              onPressed: (_isSubmitting || _isSendingReset)
                  ? null
                  : () => _handleDemoLogin(config: config, l10n: l10n),
              icon: const Icon(Icons.play_circle_outline),
              label: Text(demoLabel),
            ),
            orElse: () => TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.play_circle_outline),
              label: Text(demoLabel),
            ),
          ),
          if (configAsync is AsyncLoading<AppConfig>)
            const Padding(
              padding: EdgeInsets.only(top: ASpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );

    final double horizontalInset = size.width > 720
        ? resolvedPadding.horizontal / 2
        : resolvedPadding.horizontal;

    return Scaffold(
      backgroundColor: AColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: ASpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140F1A2E),
                    blurRadius: 28,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(ASpacing.xl),
                child: Directionality(
                  textDirection: textDirection,
                  child: form,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    try {
      await _signIn(
        email: email,
        password: password,
        source: 'form',
        l10n: l10n,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[AUTH_FLOW] login=fail type=form_unhandled error=$error source=login_page',
      );
      debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      final String message = _t(
        l10n,
        'loginErrorUnexpected',
        'אירעה תקלה. נסו שוב בעוד רגע.',
      );
      _presentInlineError(message);
    }
  }

  Future<void> _handleDemoLogin({
    required AppConfig config,
    MarketplaceLocalizations? l10n,
  }) async {
    final String? demoEmail = config.demoEmail;
    final String? demoPassword = config.demoPassword;
    if ((demoEmail == null || demoEmail.isEmpty) ||
        (demoPassword == null || demoPassword.isEmpty)) {
      _presentInlineError(
        _t(
          l10n,
          'loginErrorDemoUnavailable',
          'פרטי ההדגמה אינם זמינים בסביבה זו.',
        ),
      );
      debugPrint(
        '[AUTH_FLOW] login=fail reason=missing_demo_credentials source=login_page',
      );
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _emailController.text = demoEmail;
      _passwordController.text = demoPassword;
    });
    try {
      await _signIn(
        email: demoEmail,
        password: demoPassword,
        source: 'demo',
        l10n: l10n,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[AUTH_FLOW] login=fail type=demo_unhandled error=$error source=login_page',
      );
      debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      final String message = _t(
        l10n,
        'loginErrorDemoGeneric',
        'אירעה תקלה בעת התחברות הדמו. נסו שוב.',
      );
      _presentInlineError(message);
    }
  }

  Future<void> _signIn({
    required String email,
    required String password,
    required String source,
    MarketplaceLocalizations? l10n,
  }) async {
    if (_isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final GoTrueClient authClient = ref.read(loginAuthClientProvider);
    final ResilientAuthSignIn signIn = ResilientAuthSignIn(
      authClient: authClient,
      maxAttempts: _resilientMaxAttempts,
      onLog: (message) => debugPrint(
        '[AUTH_FLOW] $message source=login_page attempt_source=$source',
      ),
    );
    try {
      final AuthResponse response = await signIn.signInWithPassword(
        email: email,
        password: password,
      );
      final User? user = response.user ?? response.session?.user;
      final UserRole role = _resolveRole(user);
      debugPrint(
        '[AUTH_FLOW] login=ok role=${role.name} email=$email source=login_page',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = null;
      });
      _navigateToRole(role);
    } on AuthException catch (error, stackTrace) {
      debugPrint(
        '[AUTH_FLOW] login=fail type=auth status=${error.statusCode} code=${error.code} message=${error.message} source=login_page',
      );
      debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      final String message = _mapAuthExceptionToMessage(error, l10n);
      _presentInlineError(message);
    } catch (error, stackTrace) {
      debugPrint(
        '[AUTH_FLOW] login=fail type=unexpected error=$error source=login_page',
      );
      debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      final String message = _t(
        l10n,
        'loginErrorUnexpected',
        'אירעה תקלה בלתי צפויה. נסו שוב בעוד רגע.',
      );
      _presentInlineError(message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _navigateToRole(UserRole role) {
    // ניווט לפי תפקיד: admin→/admin, vendor→/vendor, אחרת→/customer
    context.go(_homePathForRole(role));
  }

  UserRole _resolveRole(User? user) {
    final Map<String, dynamic> metadata = <String, dynamic>{
      if (user?.appMetadata != null)
        ...Map<String, dynamic>.from(user!.appMetadata),
      if (user?.userMetadata != null)
        ...Map<String, dynamic>.from(user!.userMetadata!),
    };
    final String roleValue =
        (metadata['role'] as String? ?? 'buyer').toLowerCase();
    switch (roleValue) {
      case 'admin':
        return UserRole.admin;
      case 'vendor_admin':
        return UserRole.vendorAdmin;
      case 'vendor_user':
        return UserRole.vendorUser;
      case 'customer_admin':
        return UserRole.customerAdmin;
      case 'buyer':
      default:
        return UserRole.buyer;
    }
  }

  void _presentInlineError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _errorMessage = message;
    });
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  Future<void> _handleForgotPassword({MarketplaceLocalizations? l10n}) async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      _presentInlineError(
        _t(l10n, 'loginForgotPasswordMissingEmail',
            'הקלידו כתובת אימייל לפני איפוס הסיסמה.'),
      );
      return;
    }
    setState(() {
      _isSendingReset = true;
      _errorMessage = null;
    });
    try {
      final GoTrueClient authClient = ref.read(loginAuthClientProvider);
      await authClient.resetPasswordForEmail(email);
      if (!mounted) {
        return;
      }
      final String template = _t(
        l10n,
        'loginForgotPasswordSent',
        'שלחנו קישור לאיפוס הסיסמה לכתובת {email}.',
      );
      final String message = template.replaceAll('{email}', email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on AuthException catch (error) {
      final String template = _t(
        l10n,
        'loginForgotPasswordFailed',
        'לא הצלחנו לשלוח קישור איפוס: {reason}',
      );
      final String message = template.replaceAll('{reason}', error.message);
      _presentInlineError(message);
    } catch (error) {
      _presentInlineError(
        _t(
          l10n,
          'loginForgotPasswordUnknown',
          'משהו השתבש בעת שליחת קישור האיפוס. נסו שוב מאוחר יותר.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingReset = false);
      }
    }
  }

  String _mapAuthExceptionToMessage(
    AuthException error,
    MarketplaceLocalizations? l10n,
  ) {
    final String status = (error.statusCode ?? '').trim();
    final String code = (error.code ?? '').toLowerCase();
    final String message = error.message.toLowerCase();

    final bool invalidCredentials = status == '401' ||
        code == 'invalid_login_credentials' ||
        code == 'invalid_credentials' ||
        message.contains('invalid login') ||
        message.contains('invalid email or password') ||
        message.contains('invalid credentials');

    if (invalidCredentials) {
      return _t(
        l10n,
        'loginErrorGeneric',
        'לא הצלחנו להתחבר. נסו שוב בעוד רגע.',
      );
    }

    if (status == '429' ||
        code.contains('rate_limit') ||
        message.contains('rate limit')) {
      return _t(
        l10n,
        'loginErrorRateLimited',
        'בוצעו יותר מדי ניסיונות. המתינו רגע ונסו שוב.',
      );
    }

    if (code == 'email_not_confirmed' ||
        message.contains('confirm your email') ||
        message.contains('email not confirmed')) {
      return _t(
        l10n,
        'loginErrorEmailNotConfirmed',
        'האימייל טרם אומת. בדקו את תיבת הדואר לאישור.',
      );
    }

    return _t(
      l10n,
      'loginErrorGeneric',
      'לא הצלחנו להתחבר. נסו שוב בעוד רגע.',
    );
  }

  String _t(MarketplaceLocalizations? l10n, String key, String fallback) {
    final String translated = l10n?.translate(key) ?? fallback;
    return translated.isEmpty ? fallback : translated;
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({
    required this.controller,
    required this.l10n,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final MarketplaceLocalizations? l10n;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final String label = l10n?.translate('loginEmailLabel') ?? 'Email';
    final String requiredMessage =
        l10n?.translate('loginEmailRequired') ?? 'Email is required.';
    final String invalidMessage =
        l10n?.translate('loginEmailInvalid') ?? 'Enter a valid email address.';

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.ltr,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username, AutofillHints.email],
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AColors.primary, width: 2),
        ),
      ),
      onFieldSubmitted: onSubmitted,
      validator: (value) {
        final String trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return requiredMessage;
        }
        final bool basicValid = trimmed.contains('@') && trimmed.contains('.');
        if (!basicValid) {
          return invalidMessage;
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.onSubmitted,
    required this.enabled,
    required this.l10n,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String label = l10n?.translate('loginPasswordLabel') ?? 'Password';
    final String requiredMessage =
        l10n?.translate('loginPasswordRequired') ?? 'Password is required.';
    final String shortMessage =
        l10n?.translate('loginPasswordTooShort') ?? 'Password is too short.';

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textDirection: TextDirection.ltr,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AColors.primary, width: 2),
        ),
        suffixIcon: IconButton(
          onPressed: enabled ? onToggleVisibility : null,
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      onFieldSubmitted: onSubmitted,
      validator: (value) {
        if ((value ?? '').isEmpty) {
          return requiredMessage;
        }
        if ((value ?? '').length < 6) {
          return shortMessage;
        }
        return null;
      },
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('login_error_inline'),
      liveRegion: true,
      container: true,
      label: message,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AColors.dangerSurface,
          borderRadius: ARadii.md,
          border: Border.all(color: AColors.dangerBorder),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            ASpacing.md,
            ASpacing.sm,
            ASpacing.md,
            ASpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.end,
                  style: ATypography.bodyMd.copyWith(color: AColors.danger),
                ),
              ),
              const SizedBox(width: ASpacing.sm),
              const Icon(Icons.error_outline, color: AColors.danger, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _LoginSecurityCallout extends StatelessWidget {
  const _LoginSecurityCallout({required this.l10n});

  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String title = l10n?.translate('loginSecurityMfaTitle') ??
        'Protected with multi-factor authentication';
    final String body = l10n?.translate('loginSecurityMfaBody') ??
        'After signing in you will be prompted for an MFA code. Configure backup devices from the security settings screen.';

    return ACard(
      padding: const EdgeInsetsDirectional.all(ASpacing.md),
      backgroundColor: AColors.surfaceMuted,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user, color: AColors.primary),
          const SizedBox(width: ASpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ATypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AColors.primary,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: ASpacing.xs),
                Text(
                  body,
                  style: ATypography.bodySm,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
