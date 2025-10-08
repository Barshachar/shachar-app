import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/support/domain/entities/support_ticket.dart';
import 'package:ashachar_marketplace/src/features/support/domain/repositories/support_ticket_repository.dart';

class SupabaseSupportTicketRepository implements SupportTicketRepository {
  SupabaseSupportTicketRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<SupportTicket>> fetchTickets(SupportTicketStatus status) async {
    final List<dynamic> response = await _client
        .from('support_tickets')
        .select(
            'id, subject, description, status, priority, sla_due, created_at, company:companies(name), assignee:users(email)')
        .eq('status', _statusToString(status))
        .order('created_at', ascending: false);

    return response
        .map((dynamic row) => _fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  SupportTicket _fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? company =
        json['company'] as Map<String, dynamic>?;
    final Map<String, dynamic>? assignee =
        json['assignee'] as Map<String, dynamic>?;
    return SupportTicket(
      id: json['id'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String?,
      status: _statusFromString(json['status'] as String),
      priority: _priorityFromString(json['priority'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      slaDue: json['sla_due'] != null
          ? DateTime.parse(json['sla_due'] as String)
          : null,
      customerName: company?['name'] as String?,
      assignedTo: assignee?['email'] as String?,
    );
  }

  String _statusToString(SupportTicketStatus status) {
    return switch (status) {
      SupportTicketStatus.open => 'open',
      SupportTicketStatus.pending => 'pending',
      SupportTicketStatus.closed => 'closed',
    };
  }

  SupportTicketStatus _statusFromString(String value) {
    switch (value) {
      case 'pending':
        return SupportTicketStatus.pending;
      case 'closed':
        return SupportTicketStatus.closed;
      case 'open':
      default:
        return SupportTicketStatus.open;
    }
  }

  SupportTicketPriority _priorityFromString(String value) {
    switch (value) {
      case 'high':
        return SupportTicketPriority.high;
      case 'low':
        return SupportTicketPriority.low;
      case 'medium':
      default:
        return SupportTicketPriority.medium;
    }
  }
}
