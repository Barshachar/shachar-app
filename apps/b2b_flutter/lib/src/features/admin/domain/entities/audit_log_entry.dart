import 'package:equatable/equatable.dart';

enum AuditLogStatus { success, warning, error }

class AuditLogEntry extends Equatable {
  const AuditLogEntry({
    required this.timestamp,
    required this.userName,
    required this.userEmail,
    required this.action,
    required this.module,
    required this.context,
    required this.status,
    required this.client,
  });

  final DateTime timestamp;
  final String userName;
  final String userEmail;
  final String action;
  final String module;
  final String context;
  final AuditLogStatus status;
  final String client;

  @override
  List<Object> get props => <Object>[
        timestamp,
        userName,
        userEmail,
        action,
        module,
        context,
        status,
        client,
      ];
}
