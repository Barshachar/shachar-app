import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

class AdminDockSchedulingPage extends StatelessWidget {
  const AdminDockSchedulingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );

    final String title =
        l10n?.translate('adminDockSchedulingTitle') ?? 'Dock scheduling';
    final String dateRangeLabel =
        l10n?.translate('adminDockFilterDateRange') ?? 'Date Range';
    final String warehouseLabel =
        l10n?.translate('adminDockFilterWarehouse') ?? 'Warehouse';
    final String carrierLabel =
        l10n?.translate('adminDockFilterCarrier') ?? 'Carrier';
    final String statusLabel =
        l10n?.translate('adminDockFilterStatus') ?? 'Status';
    final String panelTitle =
        l10n?.translate('adminDockPanelTitle') ?? 'Dock / Door';
    final String panelTime =
        l10n?.translate('adminDockPanelTime') ?? 'Time window';
    final String panelMode = l10n?.translate('adminDockPanelMode') ?? 'Mode';
    final String specialInstructions =
        l10n?.translate('adminDockPanelSpecialInstructions') ??
            'Special instructions';
    final String liftGateLabel =
        l10n?.translate('adminDockPanelLiftGate') ?? 'Lift gate';
    final String callOnArrivalLabel =
        l10n?.translate('adminDockPanelCallOnArrival') ?? 'Call on arrival';
    final String reserveLabel =
        l10n?.translate('adminDockReserve') ?? 'Reserve slot';

    return Scaffold(
      backgroundColor: AColors.background,
      appBar: AppBar(
        title: Text(title),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth > 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ASpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: ASpacing.md,
                  runSpacing: ASpacing.md,
                  children: [
                    _FilterChip(label: dateRangeLabel, value: 'Feb 7 - Feb 14'),
                    _FilterChip(label: warehouseLabel, value: 'Warehouse 3'),
                    _FilterChip(label: carrierLabel, value: 'Carrier Fleet'),
                    _FilterChip(label: statusLabel, value: 'Scheduled'),
                  ],
                ),
                const SizedBox(height: ASpacing.xl),
                Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: wide ? 3 : 0,
                      child: _ScheduleGrid(l10n: l10n),
                    ),
                    if (wide)
                      const SizedBox(width: ASpacing.lg)
                    else
                      const SizedBox(height: ASpacing.lg),
                    Expanded(
                      flex: wide ? 2 : 0,
                      child: _ReservationPanel(
                        title: panelTitle,
                        timeLabel: panelTime,
                        modeLabel: panelMode,
                        specialInstructions: specialInstructions,
                        liftGateLabel: liftGateLabel,
                        callOnArrivalLabel: callOnArrivalLabel,
                        reserveLabel: reserveLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ASpacing.xl),
                _ScheduleLegend(l10n: l10n),
                const SizedBox(height: ASpacing.lg),
                _DockShipmentList(l10n: l10n),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: ARadii.sm,
            borderSide: const BorderSide(color: AColors.cardBorder),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ASpacing.md,
            vertical: ASpacing.sm,
          ),
        ),
        child: Text(value, style: ATypography.bodySm),
      ),
    );
  }
}

class _ScheduleGrid extends StatelessWidget {
  const _ScheduleGrid({required this.l10n});

  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final List<_DockEvent> events = [
      const _DockEvent(
          time: '7 am', label: 'Out for Deliv', color: Color(0xFF3B82F6)),
      const _DockEvent(
          time: '8 am', label: 'Deliver', color: Color(0xFF22C55E)),
      const _DockEvent(time: '9 am', label: 'Schoh', color: Color(0xFF60A5FA)),
      const _DockEvent(time: '11 am', label: 'Scour', color: Color(0xFFF97316)),
    ];

    final List<String> times = [
      '7 am',
      '8 am',
      '9 am',
      '10 am',
      '11 am',
      '12 pm',
      '1 pm',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ARadii.lg,
        border: Border.all(color: AColors.cardBorder),
      ),
      padding: const EdgeInsets.all(ASpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Feb 11 - Feb 17', style: ATypography.bodyMd),
          const SizedBox(height: ASpacing.md),
          Column(
            children: times
                .map(
                  (time) => Container(
                    margin: const EdgeInsets.only(bottom: ASpacing.sm),
                    padding: const EdgeInsets.all(ASpacing.sm),
                    decoration: BoxDecoration(
                      borderRadius: ARadii.sm,
                      border: Border.all(color: AColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(
                            time,
                            style: ATypography.bodySm
                                .copyWith(color: AColors.mutedForeground),
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: ASpacing.sm,
                            runSpacing: ASpacing.xs,
                            children: events
                                .where((event) => event.time == time)
                                .map(
                                  (event) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: ASpacing.sm,
                                      vertical: ASpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          event.color.withValues(alpha: 0.18),
                                      borderRadius: ARadii.sm,
                                    ),
                                    child: Text(
                                      event.label,
                                      style: ATypography.bodySm,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DockEvent {
  const _DockEvent({
    required this.time,
    required this.label,
    required this.color,
  });

  final String time;
  final String label;
  final Color color;
}

class _ReservationPanel extends StatelessWidget {
  const _ReservationPanel({
    required this.title,
    required this.timeLabel,
    required this.modeLabel,
    required this.specialInstructions,
    required this.liftGateLabel,
    required this.callOnArrivalLabel,
    required this.reserveLabel,
  });

  final String title;
  final String timeLabel;
  final String modeLabel;
  final String specialInstructions;
  final String liftGateLabel;
  final String callOnArrivalLabel;
  final String reserveLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ARadii.lg,
        border: Border.all(color: AColors.cardBorder),
      ),
      padding: const EdgeInsets.all(ASpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title 3', style: ATypography.titleSm),
          const SizedBox(height: ASpacing.md),
          _InputLabel(label: timeLabel, value: '9:00 – 11:00 AM'),
          const SizedBox(height: ASpacing.sm),
          _InputLabel(label: modeLabel, value: 'LTL'),
          const SizedBox(height: ASpacing.md),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(specialInstructions, style: ATypography.bodySm),
            value: false,
            onChanged: (_) {},
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(liftGateLabel, style: ATypography.bodySm),
            value: false,
            onChanged: (_) {},
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(callOnArrivalLabel, style: ATypography.bodySm),
            value: true,
            onChanged: (_) {},
            activeColor: AColors.primary,
          ),
          const SizedBox(height: ASpacing.md),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: ARadii.md),
              ),
              onPressed: () {},
              child: Text(reserveLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: ARadii.sm,
          borderSide: const BorderSide(color: AColors.cardBorder),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ASpacing.md,
          vertical: ASpacing.sm,
        ),
      ),
      child: Text(value, style: ATypography.bodySm),
    );
  }
}

class _ScheduleLegend extends StatelessWidget {
  const _ScheduleLegend({required this.l10n});

  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final List<_LegendEntry> entries = [
      _LegendEntry(
        color: const Color(0xFF1D4ED8),
        label: l10n?.translate('adminDockLegendOutForDelivery') ??
            'Out for Delivery',
      ),
      _LegendEntry(
        color: const Color(0xFF22C55E),
        label: l10n?.translate('adminDockLegendDelivered') ?? 'Delivered',
      ),
      _LegendEntry(
        color: const Color(0xFF64748B),
        label: l10n?.translate('adminDockLegendCapacity') ?? 'Capacity',
      ),
      _LegendEntry(
        color: const Color(0xFFFACC15),
        label: l10n?.translate('adminDockLegendScheduled') ?? 'Scheduled',
      ),
    ];

    return Wrap(
      spacing: ASpacing.lg,
      runSpacing: ASpacing.sm,
      children: entries
          .map(
            (entry) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: entry.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: ASpacing.xs),
                Text(entry.label, style: ATypography.bodySm),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _LegendEntry {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final String label;
}

class _DockShipmentList extends StatelessWidget {
  const _DockShipmentList({required this.l10n});

  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String trackLabel =
        l10n?.translate('adminDockActionTrack') ?? 'Track';
    final String contactLabel =
        l10n?.translate('adminDockActionContact') ?? 'Contact';
    final String rescheduleLabel =
        l10n?.translate('adminDockActionReschedule') ?? 'Reschedule';
    final String printBolLabel =
        l10n?.translate('adminDockActionPrintBol') ?? 'Print BOL';

    final List<_DockShipment> shipments = [
      _DockShipment(
        title: l10n?.translate('adminDockLegendOutForDelivery') ??
            'Out for Delivery',
        actions: [trackLabel, contactLabel, rescheduleLabel],
        accent: const Color(0xFF1D4ED8),
      ),
      _DockShipment(
        title:
            l10n?.translate('adminDockPanelCallOnArrival') ?? 'Call on arrival',
        actions: [trackLabel, rescheduleLabel, printBolLabel],
        accent: const Color(0xFFE11D48),
      ),
      _DockShipment(
        title: l10n?.translate('adminDockLegendDelivered') ?? 'Delivered',
        actions: [trackLabel, contactLabel, rescheduleLabel],
        accent: const Color(0xFF16A34A),
      ),
    ];

    return Column(
      children: shipments
          .map(
            (shipment) => Container(
              margin: const EdgeInsets.only(bottom: ASpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: ARadii.lg,
                border: Border.all(color: AColors.cardBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ASpacing.lg,
                  vertical: ASpacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 32,
                      decoration: BoxDecoration(
                        color: shipment.accent,
                        borderRadius: ARadii.xs,
                      ),
                    ),
                    const SizedBox(width: ASpacing.md),
                    Expanded(
                      child: Text(
                        shipment.title,
                        style: ATypography.bodyLg,
                      ),
                    ),
                    Wrap(
                      spacing: ASpacing.md,
                      children: shipment.actions
                          .map(
                            (action) => TextButton(
                              onPressed: () {},
                              child: Text(action),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DockShipment {
  const _DockShipment({
    required this.title,
    required this.actions,
    required this.accent,
  });

  final String title;
  final List<String> actions;
  final Color accent;
}
