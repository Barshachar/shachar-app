import 'package:ashachar_marketplace/src/features/support/domain/entities/support_ticket.dart';
import 'package:ashachar_marketplace/src/features/support/domain/repositories/support_ticket_repository.dart';

class FakeSupportTicketRepository implements SupportTicketRepository {
  const FakeSupportTicketRepository();

  static final List<SupportTicket> _tickets = <SupportTicket>[
    SupportTicket(
      id: '2034',
      subject: 'Login Issue',
      status: SupportTicketStatus.open,
      priority: SupportTicketPriority.high,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      slaDue: DateTime.now().add(const Duration(hours: 2)),
      description: 'Customer cannot access their dashboard.',
      customerName: 'SuperMart Chain',
      assignedTo: 'Ryan Williams',
    ),
    SupportTicket(
      id: '2033',
      subject: 'Order Not Delivered',
      status: SupportTicketStatus.open,
      priority: SupportTicketPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      slaDue: DateTime.now().add(const Duration(hours: 20)),
      description: 'Shipment #SM-101 missing from carrier.',
      customerName: 'Cafe Delights',
      assignedTo: 'Emily Johnson',
    ),
    SupportTicket(
      id: '2025',
      subject: 'Account Setup',
      status: SupportTicketStatus.open,
      priority: SupportTicketPriority.low,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      slaDue: DateTime.now().subtract(const Duration(hours: 4)),
      description: 'Need assistance configuring approval rules.',
      customerName: 'Hotel Plaza',
      assignedTo: 'Joseph Adams',
    ),
    SupportTicket(
      id: '2021',
      subject: 'Bulk catalog sync',
      status: SupportTicketStatus.pending,
      priority: SupportTicketPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      slaDue: DateTime.now().add(const Duration(days: 1, hours: 5)),
      description: 'Vendor provided CSV import request.',
      customerName: 'SuperMart Chain',
      assignedTo: 'Emily Johnson',
    ),
    SupportTicket(
      id: '2018',
      subject: 'Invoice reconciliation',
      status: SupportTicketStatus.closed,
      priority: SupportTicketPriority.low,
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      slaDue: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Mismatch between invoice and PO totals.',
      customerName: 'SuperMart Chain',
      assignedTo: 'Ryan Williams',
    ),
  ];

  @override
  Future<List<SupportTicket>> fetchTickets(SupportTicketStatus status) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _tickets
        .where((SupportTicket ticket) => ticket.status == status)
        .toList(growable: false);
  }
}
