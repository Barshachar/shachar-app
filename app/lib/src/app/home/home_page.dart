import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets resolvedPadding =
        context.pagePadding().resolve(Directionality.of(context));
    return Scaffold(
      appBar: AppBar(
        title: const Text('א.שחר Marketplace'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: resolvedPadding.horizontal / 2,
            vertical: ASpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'פתרון המסחר לספקים ולקוחות B2B',
                  textAlign: TextAlign.center,
                  style: ATypography.headline2,
                ),
                const SizedBox(height: ASpacing.lg),
                Text(
                  'התחברו על מנת לנהל הזמנות, קטלוגים ודיווחים בזמן אמת.',
                  textAlign: TextAlign.center,
                  style: ATypography.bodyMd,
                ),
                const SizedBox(height: ASpacing.xl),
                AButton.primary(
                  expand: true,
                  label: 'התחבר',
                  icon: const Icon(Icons.lock_open),
                  onPressed: () => context.goNamed('login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
