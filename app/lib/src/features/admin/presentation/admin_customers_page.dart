import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminCustomersPage extends ConsumerWidget {
  const AdminCustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) => ListTile(
          title: Text('Customer ${index + 1}'),
          subtitle: const Text('Assigned price lists and buyers'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
