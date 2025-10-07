import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/support/data/fake_support_ticket_repository.dart';
import 'package:ashachar_marketplace/src/features/support/data/supabase_support_ticket_repository.dart';
import 'package:ashachar_marketplace/src/features/support/domain/entities/support_ticket.dart';
import 'package:ashachar_marketplace/src/features/support/domain/repositories/support_ticket_repository.dart';

final supportTicketRepositoryProvider =
    Provider<SupportTicketRepository>((ref) {
  try {
    final SupabaseClient client = Supabase.instance.client;
    return SupabaseSupportTicketRepository(client: client);
  } catch (_) {
    return const FakeSupportTicketRepository();
  }
});

final supportTicketsProvider =
    FutureProvider.family<List<SupportTicket>, SupportTicketStatus>(
        (ref, SupportTicketStatus status) {
  final SupportTicketRepository repository =
      ref.watch(supportTicketRepositoryProvider);
  return repository.fetchTickets(status);
});
