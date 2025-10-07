import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/features/admin/data/fake_audit_log_repository.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/audit_log_entry.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/repositories/audit_log_repository.dart';

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  return const FakeAuditLogRepository();
});

final auditLogEntriesProvider = FutureProvider<List<AuditLogEntry>>((ref) {
  final AuditLogRepository repository = ref.watch(auditLogRepositoryProvider);
  return repository.fetchEntries();
});
