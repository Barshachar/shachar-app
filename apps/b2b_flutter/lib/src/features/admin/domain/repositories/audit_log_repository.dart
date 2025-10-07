import 'package:ashachar_marketplace/src/features/admin/domain/entities/audit_log_entry.dart';

abstract class AuditLogRepository {
  Future<List<AuditLogEntry>> fetchEntries();
}
