import 'package:equatable/equatable.dart';

/// Snapshot of a company's credit program state.
class BusinessCreditSnapshot extends Equatable {
  const BusinessCreditSnapshot({
    required this.creditLimit,
    required this.availableBalance,
  });

  final double creditLimit;
  final double availableBalance;

  @override
  List<Object> get props => <Object>[creditLimit, availableBalance];
}

/// Supported payment rails for the credit account.
enum PaymentMethodType { card, ach }

extension PaymentMethodTypeLabel on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.card:
        return 'Visa';
      case PaymentMethodType.ach:
        return 'ACH';
    }
  }
}

/// Payment method enrolled for repayments.
class PaymentMethod extends Equatable {
  const PaymentMethod({
    required this.type,
    required this.displayLabel,
    this.isDefault = false,
  });

  final PaymentMethodType type;
  final String displayLabel;
  final bool isDefault;

  @override
  List<Object> get props => <Object>[type, displayLabel, isDefault];
}

/// Payment term option (e.g., Net 30).
class PaymentTermOption extends Equatable {
  const PaymentTermOption({
    required this.name,
    required this.description,
  });

  final String name;
  final String description;

  @override
  List<Object> get props => <Object>[name, description];
}

/// Aggregated view for the credit settings screen.
class BusinessCreditSettings extends Equatable {
  const BusinessCreditSettings({
    required this.snapshot,
    required this.paymentMethods,
    required this.selectedTerm,
    required this.purchaseOrdersEnabled,
    required this.automaticPaymentsEnabled,
  });

  final BusinessCreditSnapshot snapshot;
  final List<PaymentMethod> paymentMethods;
  final PaymentTermOption selectedTerm;
  final bool purchaseOrdersEnabled;
  final bool automaticPaymentsEnabled;

  @override
  List<Object> get props => <Object>[
        snapshot,
        paymentMethods,
        selectedTerm,
        purchaseOrdersEnabled,
        automaticPaymentsEnabled,
      ];
}
