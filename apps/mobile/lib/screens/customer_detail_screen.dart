import 'package:flutter/material.dart';
import 'package:mobile/models/customer.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(customer.fullName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  customer.fullName.isNotEmpty
                      ? customer.fullName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                customer.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: customer.email != null && customer.email!.isNotEmpty
                  ? Text(customer.email!)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_outlined, color: Colors.green),
              title: const Text('Phone'),
              subtitle: Text(customer.phoneNumber),
            ),
          ),
          if (customer.email != null && customer.email!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.blue),
                title: const Text('Email'),
                subtitle: Text(customer.email!),
              ),
            ),
          ],
          if (customer.address != null && customer.address!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on_outlined, color: Colors.red),
                title: const Text('Address'),
                subtitle: Text(customer.address!),
              ),
            ),
          ],
          if (customer.notes != null && customer.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notes_outlined, color: Colors.orange),
                title: const Text('Notes'),
                subtitle: Text(customer.notes!),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
              title: const Text('Added'),
              subtitle: Text(
                customer.createdAt != null
                    ? '${customer.createdAt!.day}/${customer.createdAt!.month}/${customer.createdAt!.year}'
                    : 'N/A',
              ),
            ),
          ),
        ],
      ),
    );
  }
}