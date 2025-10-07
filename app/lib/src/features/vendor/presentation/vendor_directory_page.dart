import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';

class VendorDirectoryPage extends StatefulWidget {
  const VendorDirectoryPage({super.key});

  @override
  State<VendorDirectoryPage> createState() => _VendorDirectoryPageState();
}

class _VendorDirectoryPageState extends State<VendorDirectoryPage> {
  final List<_VendorCardData> _vendors = const <_VendorCardData>[
    _VendorCardData(
      name: 'Vendor name',
      onTime: 0.95,
      leadTime: 4.5,
      moq: '45 g',
      rating: 4.5,
      preferred: true,
    ),
    _VendorCardData(
      name: 'Vendor name',
      onTime: 0.92,
      leadTime: 4.5,
      moq: '20 g',
      rating: 4.5,
      preferred: false,
    ),
    _VendorCardData(
      name: 'Vendor name',
      onTime: 0.91,
      leadTime: 4.5,
      moq: '30 g',
      rating: 4.4,
      preferred: false,
    ),
  ];

  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF0D1320);
    const Color cardColor = Color(0xFF161F2D);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('Vendors'),
        actions: const [
          Icon(Icons.tune, color: Colors.white70),
          SizedBox(width: ASpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ASpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  filled: true,
                  fillColor: const Color(0xFF1E2937),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  hintStyle: ATypography.bodySm.copyWith(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: ATypography.bodyMd.copyWith(color: Colors.white),
              ),
              const SizedBox(height: ASpacing.lg),
              SegmentedButton<int>(
                segments: const <ButtonSegment<int>>[
                  ButtonSegment<int>(value: 0, label: Text('All')),
                  ButtonSegment<int>(value: 1, label: Text('Preferred')),
                  ButtonSegment<int>(value: 2, label: Text('New')),
                ],
                selected: <int>{_selectedFilter},
                onSelectionChanged: (Set<int> values) {
                  setState(() => _selectedFilter = values.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return AColors.primary.withValues(alpha: 0.25);
                      }
                      return const Color(0xFF1E2937);
                    },
                  ),
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: ASpacing.xl),
              Expanded(
                child: ListView.separated(
                  itemCount: _vendors.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: ASpacing.lg),
                  itemBuilder: (BuildContext context, int index) {
                    final _VendorCardData vendor = _vendors[index];
                    return _VendorCard(data: vendor, cardColor: cardColor);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorCardData {
  const _VendorCardData({
    required this.name,
    required this.onTime,
    required this.leadTime,
    required this.moq,
    required this.rating,
    required this.preferred,
  });

  final String name;
  final double onTime;
  final double leadTime;
  final String moq;
  final double rating;
  final bool preferred;
}

class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.data, required this.cardColor});

  final _VendorCardData data;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ASpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.name,
                style: ATypography.titleSm.copyWith(color: Colors.white),
              ),
              if (data.preferred)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Preferred',
                    style: ATypography.bodySm.copyWith(color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: ASpacing.md),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                data.rating.toStringAsFixed(1),
                style: ATypography.bodySm.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: ASpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _VendorMetric(
                  label: 'On-time %', value: '${(data.onTime * 100).round()}%'),
              _VendorMetric(label: 'Lead time', value: '${data.leadTime} m'),
              _VendorMetric(label: 'MOQ', value: data.moq),
            ],
          ),
          const SizedBox(height: ASpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  onPressed: () {},
                  child: const Text('View Catalog'),
                ),
              ),
              const SizedBox(width: ASpacing.sm),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: const Text('Contact'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VendorMetric extends StatelessWidget {
  const _VendorMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ATypography.bodySm.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: ATypography.bodySm.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
