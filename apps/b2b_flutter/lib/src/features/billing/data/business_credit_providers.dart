import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/features/billing/data/fake_business_credit_repository.dart';
import 'package:ashachar_marketplace/src/features/billing/domain/entities/business_credit_models.dart';
import 'package:ashachar_marketplace/src/features/billing/domain/repositories/business_credit_repository.dart';

final businessCreditRepositoryProvider =
    Provider<BusinessCreditRepository>((ref) {
  return const FakeBusinessCreditRepository();
});

final businessCreditSettingsProvider =
    FutureProvider<BusinessCreditSettings>((ref) {
  final BusinessCreditRepository repository =
      ref.watch(businessCreditRepositoryProvider);
  return repository.fetchSettings();
});
