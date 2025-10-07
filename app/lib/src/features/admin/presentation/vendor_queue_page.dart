import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorQueuePage extends ConsumerWidget {
  const VendorQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Approval Queue')),
      body: DataTable(
        columns: const [
          DataColumn(label: Text('Vendor')),
          DataColumn(label: Text('Submitted')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: List.generate(3, (index) {
          return DataRow(cells: [
            DataCell(Text('Vendor ${index + 1}')),
            DataCell(Text(DateTime.now()
                .subtract(Duration(days: index))
                .toIso8601String())),
            const DataCell(Text('Pending')),
            DataCell(Row(
              children: [
                TextButton(onPressed: () {}, child: const Text('Approve')),
                TextButton(onPressed: () {}, child: const Text('Reject')),
              ],
            )),
          ]);
        }),
      ),
    );
  }
}
