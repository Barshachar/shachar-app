import 'package:ashachar_marketplace/src/features/support/domain/entities/support_ticket.dart';

abstract class SupportTicketRepository {
  Future<List<SupportTicket>> fetchTickets(SupportTicketStatus status);
}
