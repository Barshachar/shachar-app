import 'package:ashachar_marketplace/src/features/billing/domain/entities/business_credit_models.dart';
import 'package:ashachar_marketplace/src/features/billing/domain/repositories/business_credit_repository.dart';

class FakeBusinessCreditRepository implements BusinessCreditRepository {
  const FakeBusinessCreditRepository();

  @override
  Future<BusinessCreditSettings> fetchSettings() async {
    // Simulate latency so the UI can show progress when needed.
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const BusinessCreditSettings(
      snapshot: BusinessCreditSnapshot(
        creditLimit: 25000,
        availableBalance: 7384,
      ),
      paymentMethods: <PaymentMethod>[
        PaymentMethod(
          type: PaymentMethodType.card,
          displayLabel: 'Visa 1234',
          isDefault: true,
        ),
        PaymentMethod(
          type: PaymentMethodType.ach,
          displayLabel: 'ACH Bank 7895',
        ),
      ],
      selectedTerm: PaymentTermOption(
        name: 'Net 30',
        description: 'Payment due 30 days after invoice.',
      ),
      purchaseOrdersEnabled: false,
      automaticPaymentsEnabled: true,
    );
  }
}
