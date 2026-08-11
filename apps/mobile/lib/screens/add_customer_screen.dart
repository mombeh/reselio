import 'package:flutter/material.dart';
import 'package:mobile/models/customer.dart';
import 'package:mobile/services/auth_service.dart';

class AddCustomerScreen extends StatefulWidget {
  final AuthService authService;
  final Customer? customer;

  const AddCustomerScreen({super.key, required this.authService, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String? _error;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.customer != null;
    if (_isEditing) {
      _fullNameController.text = widget.customer!.fullName;
      _phoneController.text = widget.customer!.phoneNumber;
      _emailController.text = widget.customer!.email ?? '';
      _addressController.text = widget.customer!.address ?? '';
      _notesController.text = widget.customer!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _error = null);

    try {
      if (_isEditing) {
        await widget.authService.apiService.updateCustomer(
          id: widget.customer!.id,
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
      } else {
        await widget.authService.apiService.createCustomer(
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Customer updated' : 'Customer added',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    appBar: AppBar(
      title: Text(
        _isEditing ? 'Edit Customer' : 'Add Customer',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      centerTitle: false,
    ),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            // Customer preview
            Center(
              child: Column(
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _fullNameController,
                    builder: (context, value, _) {
                      final name = value.text.trim();
                      final initial =
                          name.isNotEmpty ? name[0].toUpperCase() : '?';

                      return CircleAvatar(
                        radius: 42,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isEditing ? 'Update customer information' : 'New customer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEditing
                        ? 'Keep the customer details up to date'
                        : 'Add a customer to your Reselio business',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Error message
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Basic information
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            _buildFormCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter customer name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a full name';
                      }
                      return null;
                    },
                  ),
                  const Divider(height: 1),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+237 6XX XXX XXX',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a phone number';
                      }

                      final phoneRegex =
                          RegExp(r'^[+]?[\d\s()-]{7,20}$');

                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid phone number';
                      }

                      return null;
                    },
                  ),
                  const Divider(height: 1),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'customer@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      suffixText: 'Optional',
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Additional information
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            _buildFormCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter customer address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      suffixText: 'Optional',
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                  ),
                  const Divider(height: 1),
                  TextFormField(
                    controller: _notesController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Add any useful information...',
                      prefixIcon: Icon(Icons.notes_outlined),
                      suffixText: 'Optional',
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: widget.authService.isLoading
                    ? null
                    : _handleSubmit,
                icon: widget.authService.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _isEditing
                            ? Icons.save_outlined
                            : Icons.person_add_outlined,
                      ),
                label: Text(
                  widget.authService.isLoading
                      ? (_isEditing ? 'Updating...' : 'Adding...')
                      : (_isEditing
                          ? 'Update Customer'
                          : 'Add Customer'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'Required fields are marked above',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFormCard({
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: child,
    ),
  );
}
}