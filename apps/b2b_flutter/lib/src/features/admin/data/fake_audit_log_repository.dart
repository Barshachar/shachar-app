import 'package:ashachar_marketplace/src/features/admin/domain/entities/audit_log_entry.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/repositories/audit_log_repository.dart';

class FakeAuditLogRepository implements AuditLogRepository {
  const FakeAuditLogRepository();

  static final List<AuditLogEntry> _entries = <AuditLogEntry>[
    AuditLogEntry(
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      userName: 'Lucas Nguyen',
      userEmail: 'lucas@example.com',
      action: 'Updated Product: Rolling Scaffold',
      module: 'Catalog',
      context: 'Desktop • 192.12.0.7',
      status: AuditLogStatus.success,
      client: 'Fronter',
    ),
    AuditLogEntry(
      timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
      userName: 'Maria Clark',
      userEmail: 'maria@example.com',
      action: 'Deleted List Item: Protective Gloves',
      module: 'Lists',
      context: 'Desktop • 172.27.0.0',
      status: AuditLogStatus.success,
      client: 'Fronter',
    ),
    AuditLogEntry(
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 10)),
      userName: 'James Smith',
      userEmail: 'james.smith@example.com',
      action: 'Impersonated Client Portal',
      module: 'Security',
      context: 'Mobile • 10.0.1.96',
      status: AuditLogStatus.warning,
      client: 'Fronter',
    ),
    AuditLogEntry(
      timestamp: DateTime.now().subtract(const Duration(hours: 6, minutes: 40)),
      userName: 'Emily Jones',
      userEmail: 'emily.jones@example.com',
      action: 'Assigned Ticket IN-1006',
      module: 'Support',
      context: 'Desktop • 203.0.113.5',
      status: AuditLogStatus.success,
      client: 'Fronter',
    ),
  ];

  @override
  Future<List<AuditLogEntry>> fetchEntries() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _entries;
  }
}
