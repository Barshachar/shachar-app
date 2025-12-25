import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/admin/data/supabase_audit_log_repository.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/audit_log_entry.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/repositories/audit_log_repository.dart';

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  return SupabaseAuditLogRepository(client: client);
});

final auditLogEntriesProvider = FutureProvider<List<AuditLogEntry>>((ref) {
  final AuditLogRepository repository = ref.watch(auditLogRepositoryProvider);
  return repository.fetchEntries();
});
