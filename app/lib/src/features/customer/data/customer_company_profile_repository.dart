import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/customer/domain/customer_company_profile.dart';

final customerCompanyProfileRepositoryProvider =
    Provider<CustomerCompanyProfileRepository>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  return SupabaseCustomerCompanyProfileRepository(client: client);
});

abstract class CustomerCompanyProfileRepository {
  Future<CustomerCompanyProfile> fetchProfile({String? companyId});
}

class SupabaseCustomerCompanyProfileRepository
    implements CustomerCompanyProfileRepository {
  SupabaseCustomerCompanyProfileRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<CustomerCompanyProfile> fetchProfile({String? companyId}) async {
    PostgrestFilterBuilder<dynamic> query = _client
        .from('customer_profiles')
        .select(
            'customer_id, account_tier, industry, sales_rep_name, sales_rep_email, phone, street_address, city, postal_code, country, company:companies(name,status)');
    if (companyId != null && companyId.isNotEmpty) {
      query = query.eq('customer_id', companyId);
    }
    final Map<String, dynamic> row = await query.limit(1).single();
    final Map<String, dynamic>? company =
        row['company'] as Map<String, dynamic>?;

    return CustomerCompanyProfile(
      companyId: row['customer_id'] as String,
      companyName: company?['name'] as String? ?? 'Unknown company',
      status: company?['status'] as String? ?? 'active',
      tier: row['account_tier'] as String? ?? 'Standard',
      industry: row['industry'] as String? ?? 'General',
      salesRepName: row['sales_rep_name'] as String? ?? '-',
      salesRepEmail: row['sales_rep_email'] as String? ?? '-',
      phone: row['phone'] as String? ?? '-',
      addressLine: row['street_address'] as String? ?? '',
      city: row['city'] as String? ?? '',
      postalCode: row['postal_code'] as String? ?? '',
      country: row['country'] as String? ?? '',
    );
  }
}
