import 'package:ashachar_marketplace/src/features/billing/domain/entities/business_credit_models.dart';

abstract class BusinessCreditRepository {
  Future<BusinessCreditSettings> fetchSettings();
}
