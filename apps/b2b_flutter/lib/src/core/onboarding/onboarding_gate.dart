import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/core/onboarding/onboarding_service.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeShowOnboarding();
  }

  void _maybeShowOnboarding() {
    if (_checked) {
      return;
    }
    _checked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await OnboardingService.showOnboardingIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
