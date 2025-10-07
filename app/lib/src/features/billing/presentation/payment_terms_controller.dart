import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:state_notifier/state_notifier.dart';

import 'package:ashachar_marketplace/src/auth/user_profile_provider.dart';
import 'package:ashachar_marketplace/src/features/billing/data/payment_terms_repository.dart';
import 'package:ashachar_marketplace/src/features/billing/domain/payment_terms_models.dart';

final paymentTermsFormProvider = legacy.StateNotifierProvider.autoDispose<
    PaymentTermsFormNotifier, VendorPaymentTermsProfile?>((ref) {
  return PaymentTermsFormNotifier();
});

class PaymentTermsFormNotifier
    extends StateNotifier<VendorPaymentTermsProfile?> {
  PaymentTermsFormNotifier() : super(null);

  void setProfile(VendorPaymentTermsProfile profile) {
    state = profile;
  }

  void setDefaultTerms(String termsId) {
    final VendorPaymentTermsProfile? current = state;
    if (current == null) return;
    final Set<String> allowed = Set<String>.from(current.allowedTermIds)
      ..add(termsId);
    state = current.copyWith(
      defaultTermsId: termsId,
      allowedTermIds: allowed,
    );
  }

  void toggleAllowedTerms(String termsId, bool allowed) {
    final VendorPaymentTermsProfile? current = state;
    if (current == null) return;
    final Set<String> updated = Set<String>.from(current.allowedTermIds);
    if (allowed) {
      updated.add(termsId);
    } else {
      if (termsId != current.defaultTermsId) {
        updated.remove(termsId);
      }
    }
    state = current.copyWith(allowedTermIds: updated);
  }

  void setEarlyDiscount({bool enabled = true, double? pct, int? days}) {
    final VendorPaymentTermsProfile? current = state;
    if (current == null) return;
    if (!enabled) {
      state = current.copyWith(
        clearEarlyPayDiscount: true,
        clearEarlyPayDays: true,
      );
      return;
    }
    state = current.copyWith(
      earlyPayDiscountPct: pct ?? current.earlyPayDiscountPct,
      earlyPayDiscountDays: days ?? current.earlyPayDiscountDays,
    );
  }

  void setLateFee(double? pct) {
    final VendorPaymentTermsProfile? current = state;
    if (current == null) return;
    if (pct == null) {
      state = current.copyWith(clearLateFee: true);
      return;
    }
    state = current.copyWith(lateFeeInterestPct: pct);
  }

  void setGracePeriod(int? days) {
    final VendorPaymentTermsProfile? current = state;
    if (current == null) return;
    if (days == null) {
      state = current.copyWith(clearGracePeriod: true);
      return;
    }
    state = current.copyWith(gracePeriodDays: days);
  }

  void setAllowOverrides(bool allow) {
    final VendorPaymentTermsProfile? current = state;
    if (current == null) return;
    state = current.copyWith(allowOverrides: allow);
  }

  void setOverrides(List<VendorPaymentTermOverride> overrides) {
    final VendorPaymentTermsProfile? current = state;
    if (current == null) return;
    state = current.copyWith(overrides: overrides);
  }
}

final vendorPaymentTermsProvider = legacy.StateNotifierProvider.autoDispose<
    VendorPaymentTermsController, AsyncValue<VendorPaymentTermsProfile>>((ref) {
  return VendorPaymentTermsController(ref);
});

class VendorPaymentTermsController
    extends StateNotifier<AsyncValue<VendorPaymentTermsProfile>> {
  VendorPaymentTermsController(this._ref)
      : super(const AsyncValue<VendorPaymentTermsProfile>.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final profileAsync = _ref.read(userProfileProvider);
    final String? vendorId = profileAsync.asData?.value?.companyId;
    if (vendorId == null || vendorId.isEmpty) {
      state = AsyncValue<VendorPaymentTermsProfile>.error(
        StateError('Vendor context required'),
        StackTrace.current,
      );
      return;
    }
    final PaymentTermsRepository repository =
        _ref.read(paymentTermsRepositoryProvider);
    try {
      final VendorPaymentTermsProfile profile =
          await repository.fetchProfile(vendorId: vendorId);
      _ref.read(paymentTermsFormProvider.notifier).setProfile(profile);
      state = AsyncValue<VendorPaymentTermsProfile>.data(profile);
    } catch (error, stack) {
      state = AsyncValue<VendorPaymentTermsProfile>.error(error, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue<VendorPaymentTermsProfile>.loading();
    await _load();
  }

  Future<void> save(VendorPaymentTermsProfile profile) async {
    final PaymentTermsRepository repository =
        _ref.read(paymentTermsRepositoryProvider);
    await repository.saveProfile(profile);
    _ref.read(paymentTermsFormProvider.notifier).setProfile(profile);
    state = AsyncValue<VendorPaymentTermsProfile>.data(profile);
  }

  Future<void> addOverride({
    required String vendorId,
    required String customerId,
    required String termsId,
  }) async {
    final PaymentTermsRepository repository =
        _ref.read(paymentTermsRepositoryProvider);
    await repository.upsertOverride(
      vendorId: vendorId,
      customerId: customerId,
      termsId: termsId,
    );
    await refresh();
  }

  Future<void> removeOverride(String overrideId) async {
    final PaymentTermsRepository repository =
        _ref.read(paymentTermsRepositoryProvider);
    await repository.removeOverride(overrideId);
    await refresh();
  }
}
