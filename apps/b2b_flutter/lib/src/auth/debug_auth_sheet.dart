import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/auth/auth_resilience.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';

Future<void> showDebugAuthSheet(BuildContext context, WidgetRef ref) async {
  final bool debugFeaturesEnabled = ref.read(debugFeaturesEnabledProvider);
  if (!debugFeaturesEnabled) {
    return;
  }
  final SupabaseClient supabase = Supabase.instance.client;
  final AppConfig config = await ref.read(appConfigProvider.future);
  if (!context.mounted) {
    return;
  }

  final String initialEmail =
      supabase.auth.currentUser?.email ?? config.demoEmail ?? '';
  final String initialPassword = config.demoPassword ?? '';
  final String initialStatus = supabase.auth.currentUser != null
      ? 'Signed in as ${supabase.auth.currentUser?.email}'
      : 'Not signed in';

  await showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext _) {
      return _DebugAuthSheet(
        supabaseClient: supabase,
        initialEmail: initialEmail,
        initialPassword: initialPassword,
        initialStatusMessage: initialStatus,
        debugFeaturesEnabled: debugFeaturesEnabled,
      );
    },
  );
}

class _DebugAuthSheet extends StatefulWidget {
  const _DebugAuthSheet({
    required this.supabaseClient,
    required this.initialEmail,
    required this.initialPassword,
    required this.initialStatusMessage,
    required this.debugFeaturesEnabled,
  });

  final SupabaseClient supabaseClient;
  final String initialEmail;
  final String initialPassword;
  final String initialStatusMessage;
  final bool debugFeaturesEnabled;

  @override
  State<_DebugAuthSheet> createState() => _DebugAuthSheetState();
}

class _DebugAuthSheetState extends State<_DebugAuthSheet> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final ResilientAuthSignIn _resilientSignIn;
  late String _statusMessage;

  String _homePathForRole(String? role, {String? companyType}) {
    final String normalizedRole = (role ?? '').toLowerCase().trim();
    switch (normalizedRole) {
      case 'admin':
        return '/admin';
      case 'vendor_admin':
      case 'vendor_user':
      case 'vendor':
        return '/vendor';
      case 'customer_admin':
      case 'buyer':
        return '/customer';
    }

    final String normalizedCompanyType =
        (companyType ?? '').toLowerCase().trim();
    switch (normalizedCompanyType) {
      case 'admin':
        return '/admin';
      case 'vendor':
        return '/vendor';
      case 'customer':
        return '/customer';
    }

    return '/customer';
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _passwordController = TextEditingController(text: widget.initialPassword);
    _statusMessage = widget.initialStatusMessage;
    _resilientSignIn = ResilientAuthSignIn(
      authClient: widget.supabaseClient.auth,
      onLog: (message) =>
          debugPrint('[AUTH_FLOW] $message source=debug_auth_sheet'),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showErrorSnack(String message) async {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('ההתחברות נכשלה: $message'),
        ),
      );
    if (!mounted) {
      return;
    }
    setState(() {
      _statusMessage = 'Sign-in failed: $message';
    });
  }

  Future<void> _navigateTo(String routeName) async {
    if (!mounted) {
      return;
    }
    debugPrint(
      '[AUTH_FLOW] login=debug_nav route=$routeName source=debug_auth_sheet',
    );
    context.goNamed(routeName);
    if (!mounted) {
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _navigateToPath(String path) async {
    if (!mounted) {
      return;
    }
    debugPrint(
      '[AUTH_FLOW] login=debug_nav path=$path source=debug_auth_sheet',
    );
    context.go(path);
    if (!mounted) {
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Set<String> _normalizedRoles() {
    final User? user = widget.supabaseClient.auth.currentUser;
    if (user == null) {
      return const <String>{};
    }
    final Map<String, dynamic> metadata = <String, dynamic>{
      ...user.appMetadata,
      if (user.userMetadata != null)
        ...Map<String, dynamic>.from(user.userMetadata!),
    };
    final Set<String> roles = <String>{};

    void addRole(Object? value) {
      if (value is String) {
        final String normalized = value.trim().toLowerCase();
        if (normalized.isNotEmpty) {
          roles.add(normalized);
        }
      } else if (value is Iterable) {
        for (final Object? entry in value) {
          addRole(entry);
        }
      }
    }

    addRole(metadata['role']);
    addRole(metadata['roles']);
    addRole(metadata['company_type']);
    return roles;
  }

  Future<void> _signIn() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (!mounted) {
      return;
    }

    debugPrint(
      '[AUTH_FLOW] login=attempt source=debug_auth_sheet user=$email',
    );

    try {
      try {
        await widget.supabaseClient.auth.signOut();
        if (!mounted) {
          return;
        }
        debugPrint(
          '[AUTH_FLOW] login=info action=pre_signout_ok source=debug_auth_sheet',
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[AUTH_FLOW] login=pre_signout_failed source=debug_auth_sheet error=$error',
        );
        debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      }

      final AuthResponse result = await _resilientSignIn.signInWithPassword(
          email: email, password: password);
      if (!mounted) {
        return;
      }

      final User? user = result.user ?? result.session?.user;
      final Map<String, dynamic> metadata = <String, dynamic>{
        ...?user?.appMetadata,
        if (user?.userMetadata != null) ...user!.userMetadata!,
      };
      final String roleValue = metadata['role'] as String? ?? '';
      final String companyType = metadata['company_type'] as String? ?? '';
      final String companyId = (metadata['company_id'] as String? ?? '').trim();
      final String routeName = _homeRouteForRole(
        roleValue,
        companyType: companyType,
      );
      final String routePath = _homePathForRole(
        roleValue,
        companyType: companyType,
      );
      final String userIdentifier = user?.email ?? user?.id ?? 'unknown-user';

      if (companyId.isEmpty) {
        debugPrint(
          '[AUTH_FLOW] login=warn missing_company_id user=$userIdentifier source=debug_auth_sheet',
        );
      }

      debugPrint(
        "[AUTH_FLOW] login=ok company_id=${companyId.isEmpty ? 'n/a' : companyId} user=$userIdentifier route=$routeName path=$routePath source=debug_auth_sheet",
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage =
            'Sign-in ok: $userIdentifier (company_id: ${companyId.isEmpty ? 'n/a' : companyId})';
      });

      await _navigateToPath(routePath);
    } on AuthException catch (error, stackTrace) {
      debugPrint(
        "[AUTH_FLOW] login=fail type=auth status=${error.statusCode ?? 'n/a'} message=${error.message} source=debug_auth_sheet",
      );
      debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      await _showErrorSnack(
        error.message.isNotEmpty ? error.message : 'Authentication error',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[AUTH_FLOW] login=fail type=unexpected error=$error source=debug_auth_sheet',
      );
      debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      await _showErrorSnack(error.toString());
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.supabaseClient.auth.signOut();
      if (!mounted) {
        return;
      }
      debugPrint(
        '[AUTH_FLOW] login=signout_ok source=debug_auth_sheet',
      );
      setState(() {
        _statusMessage = 'Signed out';
      });
    } catch (error, stackTrace) {
      debugPrint(
        '[AUTH_FLOW] login=signout_failed source=debug_auth_sheet error=$error',
      );
      debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      await _showErrorSnack('Failed to sign out: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> roles = _normalizedRoles();
    final bool debugEnabled = widget.debugFeaturesEnabled || kDebugMode;
    final bool canNavigateAdmin = debugEnabled || roles.contains('admin');
    final bool canNavigateVendor = debugEnabled ||
        roles.contains('vendor') ||
        roles.contains('vendor_admin') ||
        roles.contains('vendor_user');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Debug Auth',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Sign in'),
              ),
              OutlinedButton(
                onPressed: _signOut,
                child: const Text('Sign out'),
              ),
              if (canNavigateAdmin)
                OutlinedButton(
                  onPressed: () => _navigateTo('admin-home'),
                  child: const Text('Go /admin'),
                ),
              if (canNavigateVendor)
                OutlinedButton(
                  onPressed: () => _navigateTo('vendor-home'),
                  child: const Text('Go /vendor'),
                ),
              OutlinedButton(
                onPressed: () => _navigateTo('customer-home'),
                child: const Text('Go /customer'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_statusMessage),
        ],
      ),
    );
  }
}

String _homeRouteForRole(String role, {String? companyType}) {
  final String normalizedRole = role.toLowerCase().trim();
  switch (normalizedRole) {
    case 'admin':
      return 'admin-home';
    case 'vendor_admin':
    case 'vendor_user':
      return 'vendor-home';
    case 'customer_admin':
    case 'buyer':
      return 'customer-home';
  }

  final String normalizedCompanyType = (companyType ?? '').toLowerCase().trim();
  switch (normalizedCompanyType) {
    case 'admin':
      return 'admin-home';
    case 'vendor':
      return 'vendor-home';
    case 'customer':
      return 'customer-home';
  }

  return 'customer-home';
}
