import 'package:equatable/equatable.dart';

enum SupportTicketStatus { open, pending, closed }

enum SupportTicketPriority { high, medium, low }

class SupportTicket extends Equatable {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.description,
    this.customerName,
    this.assignedTo,
    this.slaDue,
  });

  final String id;
  final String subject;
  final String? description;
  final SupportTicketStatus status;
  final SupportTicketPriority priority;
  final DateTime createdAt;
  final String? customerName;
  final String? assignedTo;
  final DateTime? slaDue;

  bool get isOverdue => slaDue != null && slaDue!.isBefore(DateTime.now());

  String get slaCountdown {
    if (slaDue == null) {
      return 'No SLA';
    }
    final Duration diff = slaDue!.difference(DateTime.now());
    final Duration positive = diff.isNegative ? diff.abs() : diff;
    final int hours = positive.inHours;
    final int minutes = positive.inMinutes.remainder(60);
    final int seconds = positive.inSeconds.remainder(60);
    final String hh = hours.toString().padLeft(2, '0');
    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = seconds.toString().padLeft(2, '0');
    return diff.isNegative ? '-$hh:$mm:$ss' : '$hh:$mm:$ss';
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        subject,
        description,
        status,
        priority,
        createdAt,
        customerName,
        assignedTo,
        slaDue,
      ];
}
