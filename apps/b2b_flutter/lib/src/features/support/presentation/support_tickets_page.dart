import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/features/support/data/support_providers.dart';
import 'package:ashachar_marketplace/src/features/support/domain/entities/support_ticket.dart';

class SupportTicketsPage extends ConsumerWidget {
  const SupportTicketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support Tickets'),
          backgroundColor: AColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Open'),
              Tab(text: 'Pending'),
              Tab(text: 'Closed'),
            ],
          ),
        ),
        backgroundColor: AColors.background,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.white,
          foregroundColor: AColors.primary,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('New ticket action not implemented.')),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New Ticket'),
        ),
        body: TabBarView(
          children: const [
            _SupportTicketList(status: SupportTicketStatus.open),
            _SupportTicketList(status: SupportTicketStatus.pending),
            _SupportTicketList(status: SupportTicketStatus.closed),
          ],
        ),
      ),
    );
  }
}

class _SupportTicketList extends ConsumerWidget {
  const _SupportTicketList({
    required this.status,
  });

  final SupportTicketStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SupportTicket>> ticketsAsync =
        ref.watch(supportTicketsProvider(status));
    final EdgeInsets padding =
        context.pagePadding().resolve(Directionality.of(context));

    return ticketsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => Center(
        child: Text('Unable to load tickets\n$error'),
      ),
      data: (List<SupportTicket> tickets) {
        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.support_agent,
                    size: 48, color: AColors.mutedForeground),
                const SizedBox(height: ASpacing.md),
                Text(
                  'No tickets in this queue',
                  style: ATypography.bodyLg
                      .copyWith(color: AColors.mutedForeground),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: padding,
          itemCount: tickets.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: ASpacing.md),
              child: _TicketCard(ticket: tickets[index]),
            );
          },
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat('MMM d, yyyy');
    final String createdDate = dateFormat.format(ticket.createdAt);
    final String slaCountdown = ticket.slaCountdown;
    final bool overdue = ticket.isOverdue;
    final TextStyle metaStyle = ATypography.bodySm.copyWith(
      color: overdue ? AColors.danger : AColors.mutedForeground,
    );
    final TextStyle descriptionStyle =
        ATypography.bodySm.copyWith(color: AColors.neutral600);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PriorityChip(priority: ticket.priority),
                const SizedBox(width: ASpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.subject,
                        style: ATypography.titleSm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: ASpacing.xs),
                      Text(
                        ticket.customerName ?? 'General support',
                        style: ATypography.bodySm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.md),
            Text(
              ticket.description ?? 'No additional details provided.',
              style: descriptionStyle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: ASpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Opened $createdDate', style: ATypography.bodySm),
                    const SizedBox(height: ASpacing.xs),
                    Text('Assigned to ${ticket.assignedTo ?? 'Unassigned'}',
                        style: ATypography.bodySm),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ASpacing.lg,
                    vertical: ASpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: overdue ? AColors.dangerSurface : AColors.neutral200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 18, color: AColors.mutedForeground),
                      const SizedBox(width: ASpacing.xs),
                      Text(
                        'SLA $slaCountdown',
                        style: metaStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: overdue ? AColors.danger : AColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Add attachment',
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file_outlined),
                  color: AColors.mutedForeground,
                ),
                IconButton(
                  tooltip: 'Reply',
                  onPressed: () {},
                  icon: const Icon(Icons.reply_all_outlined),
                  color: AColors.mutedForeground,
                ),
                IconButton(
                  tooltip: 'Open details',
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final SupportTicketPriority priority;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (priority) {
      SupportTicketPriority.high => (AColors.danger, 'HIGH'),
      SupportTicketPriority.medium => (AColors.warning, 'MEDIUM'),
      SupportTicketPriority.low => (AColors.neutral400, 'LOW'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: ATypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
