import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/billing/domain/payment_terms_models.dart';

final paymentTermsRepositoryProvider = Provider<PaymentTermsRepository>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  return SupabasePaymentTermsRepository(client: client);
});

abstract class PaymentTermsRepository {
  Future<VendorPaymentTermsProfile> fetchProfile({required String vendorId});
  Future<void> saveProfile(VendorPaymentTermsProfile profile);
  Future<void> upsertOverride({
    required String vendorId,
    required String customerId,
    required String termsId,
  });
  Future<void> removeOverride(String overrideId);
  Future<List<Map<String, dynamic>>> searchCustomers(String query);
}

class SupabasePaymentTermsRepository implements PaymentTermsRepository {
  SupabasePaymentTermsRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<VendorPaymentTermsProfile> fetchProfile(
      {required String vendorId}) async {
    final List<dynamic> templatesResponse = await _client
        .from('payment_terms_templates')
        .select()
        .order('net_days');
    final List<PaymentTermsTemplate> templates = templatesResponse
        .map((dynamic row) => _parseTemplate(row as Map<String, dynamic>))
        .toList(growable: false);

    final Map<String, dynamic>? settings = await _client
        .from('vendor_payment_term_settings')
        .select()
        .eq('vendor_id', vendorId)
        .maybeSingle();

    final List<dynamic> optionsResponse = await _client
        .from('vendor_payment_term_options')
        .select('terms_id,is_allowed')
        .eq('vendor_id', vendorId);

    final Set<String> allowed = optionsResponse.isEmpty
        ? templates.map((PaymentTermsTemplate t) => t.id).toSet()
        : optionsResponse
            .where((dynamic row) =>
                (row as Map<String, dynamic>)['is_allowed'] == true)
            .map((dynamic row) =>
                (row as Map<String, dynamic>)['terms_id'] as String)
            .toSet();

    String defaultTermsId;
    double? earlyDiscountPct;
    int? earlyDiscountDays;
    double? lateFeeInterestPct;
    int? gracePeriodDays;
    bool allowOverrides = false;

    if (settings != null) {
      defaultTermsId = settings['default_terms_id'] as String? ??
          (templates.isNotEmpty ? templates.first.id : '');
      earlyDiscountPct =
          (settings['early_pay_discount_pct'] as num?)?.toDouble();
      earlyDiscountDays = (settings['early_pay_discount_days'] as int?);
      lateFeeInterestPct =
          (settings['late_fee_interest_pct'] as num?)?.toDouble();
      gracePeriodDays = settings['grace_period_days'] as int?;
      allowOverrides = settings['allow_vendor_overrides'] as bool? ?? false;
    } else {
      defaultTermsId = templates.isNotEmpty ? templates.first.id : '';
    }

    if (defaultTermsId.isEmpty && templates.isNotEmpty) {
      defaultTermsId = templates.first.id;
    }
    allowed.add(defaultTermsId);

    final List<dynamic> overridesResponse = await _client
        .from('vendor_payment_term_overrides')
        .select(
            'id, customer_id, terms_id, customer:companies(name), term:payment_terms_templates(display_name)')
        .eq('vendor_id', vendorId);
    final List<VendorPaymentTermOverride> overrides = overridesResponse
        .map((dynamic row) => _parseOverride(row as Map<String, dynamic>))
        .toList(growable: false);

    return VendorPaymentTermsProfile(
      vendorId: vendorId,
      templates: templates,
      allowedTermIds: allowed,
      defaultTermsId: defaultTermsId,
      earlyPayDiscountPct: earlyDiscountPct,
      earlyPayDiscountDays: earlyDiscountDays,
      lateFeeInterestPct: lateFeeInterestPct,
      gracePeriodDays: gracePeriodDays,
      allowOverrides: allowOverrides,
      overrides: overrides,
    );
  }

  @override
  Future<void> saveProfile(VendorPaymentTermsProfile profile) async {
    await _client.from('vendor_payment_term_settings').upsert(
      <String, dynamic>{
        'vendor_id': profile.vendorId,
        'default_terms_id': profile.defaultTermsId,
        'early_pay_discount_pct': profile.earlyPayDiscountPct,
        'early_pay_discount_days': profile.earlyPayDiscountDays,
        'late_fee_interest_pct': profile.lateFeeInterestPct,
        'grace_period_days': profile.gracePeriodDays,
        'allow_vendor_overrides': profile.allowOverrides,
      },
    );

    final List<Map<String, dynamic>> optionPayload = profile.templates
        .map(
          (PaymentTermsTemplate template) => <String, dynamic>{
            'vendor_id': profile.vendorId,
            'terms_id': template.id,
            'is_allowed': profile.allowedTermIds.contains(template.id) ||
                template.id == profile.defaultTermsId,
          },
        )
        .toList(growable: false);

    await _client
        .from('vendor_payment_term_options')
        .upsert(optionPayload, onConflict: 'vendor_id,terms_id');
  }

  @override
  Future<void> upsertOverride({
    required String vendorId,
    required String customerId,
    required String termsId,
  }) async {
    await _client.from('vendor_payment_term_overrides').upsert(
      <String, dynamic>{
        'vendor_id': vendorId,
        'customer_id': customerId,
        'terms_id': termsId,
      },
      onConflict: 'vendor_id,customer_id',
    );
  }

  @override
  Future<void> removeOverride(String overrideId) async {
    await _client
        .from('vendor_payment_term_overrides')
        .delete()
        .eq('id', overrideId);
  }

  @override
  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    final List<dynamic> response = await _client
        .from('companies')
        .select('id,name')
        .eq('type', 'customer')
        .ilike('name', '%$query%')
        .limit(10);
    return response
        .map((dynamic row) => row as Map<String, dynamic>)
        .toList(growable: false);
  }

  PaymentTermsTemplate _parseTemplate(Map<String, dynamic> json) {
    return PaymentTermsTemplate(
      id: json['id'] as String,
      code: json['code'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String?,
      netDays: json['net_days'] as int,
    );
  }

  VendorPaymentTermOverride _parseOverride(Map<String, dynamic> json) {
    final Map<String, dynamic>? customer =
        json['customer'] as Map<String, dynamic>?;
    final Map<String, dynamic>? term = json['term'] as Map<String, dynamic>?;
    return VendorPaymentTermOverride(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      customerName: customer?['name'] as String? ?? 'Unknown customer',
      termsId: json['terms_id'] as String,
      termsDisplayName: term?['display_name'] as String? ?? '',
    );
  }
}
