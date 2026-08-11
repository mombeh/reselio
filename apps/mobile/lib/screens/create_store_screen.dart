import 'package:flutter/material.dart';
import 'package:mobile/models/store.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/services/auth_service.dart';

class CreateStoreScreen extends StatefulWidget {
  final AuthService authService;
  final Store? store;

  const CreateStoreScreen({
    super.key,
    required this.authService,
    this.store,
  });

  @override
  State<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  static const Color primary = Color(0xFF6C3FC5);
  static const Color background = Color(0xFFF9F7FC);
  static const Color textPrimary = Color(0xFF242029);
  static const Color textSecondary = Color(0xFF77727F);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _logoController = TextEditingController();

  String? _error;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _isEditing = widget.store != null;

    if (_isEditing) {
      _nameController.text = widget.store!.name;
      _descriptionController.text = widget.store!.description;
      _phoneController.text = widget.store!.phone;
      _addressController.text = widget.store!.address;
      _logoController.text = widget.store!.logo ?? '';
    }

    _logoController.addListener(_onLogoChanged);
  }

  void _onLogoChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _logoController.removeListener(_onLogoChanged);
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _error = null;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();
      final logo = _logoController.text.trim();

      if (_isEditing) {
        await widget.authService.apiService.updateStore(
          name: name,
          description: description,
          phone: phone,
          address: address,
          logo: logo.isNotEmpty ? logo : null,
        );
      } else {
        await widget.authService.apiService.createStore(
          name: name,
          description: description,
          phone: phone,
          address: address,
          logo: logo.isNotEmpty ? logo : null,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isEditing
                      ? 'Store updated successfully'
                      : 'Store created successfully',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRouter.myStore,
        arguments: {
          'authService': widget.authService,
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String? _validateRequired(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    final phone = value.trim();

    final phoneRegex = RegExp(r'^[+]?[\d\s()-]{7,20}$');

    if (!phoneRegex.hasMatch(phone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  String? _validateLogoUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(value.trim());

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.authService.isLoading;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _isEditing ? 'Edit Store' : 'Create Store',
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(
          color: textPrimary,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              if (_error != null) ...[
                _buildErrorMessage(),
                const SizedBox(height: 20),
              ],

              _buildSectionTitle(
                'Store information',
                'Tell your customers about your business.',
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: _nameController,
                label: 'Store Name',
                hint: 'e.g. Nadine Fashion Store',
                icon: Icons.store_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) => _validateRequired(
                  value,
                  'Please enter your store name',
                ),
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe what your store sells...',
                icon: Icons.description_outlined,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                validator: (value) => _validateRequired(
                  value,
                  'Please enter a description',
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(
                'Contact information',
                'How can customers reach your store?',
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+237 6XX XXX XXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: _validatePhone,
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: _addressController,
                label: 'Address',
                hint: 'e.g. Yaoundé, Cameroon',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                textInputAction: TextInputAction.next,
                validator: (value) => _validateRequired(
                  value,
                  'Please enter your address',
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(
                'Store branding',
                'Add a logo to personalize your store.',
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: _logoController,
                label: 'Logo URL',
                hint: 'https://example.com/logo.png',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                validator: _validateLogoUrl,
              ),

              if (_logoController.text.trim().isNotEmpty &&
                  _validateLogoUrl(_logoController.text) == null) ...[
                const SizedBox(height: 14),
                _buildLogoPreview(),
              ],

              const SizedBox(height: 28),

              _buildSubmitButton(isLoading),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'You can update your store information later.',
                  textAlign: TextAlign.center,
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C3FC5),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? 'Update your store'
                      : 'Set up your store',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isEditing
                      ? 'Keep your store information up to date.'
                      : 'Create your store profile and start managing your business.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        color: textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: 14,
            right: maxLines > 1 ? 8 : 0,
            top: maxLines > 1 ? 14 : 0,
          ),
          child: Icon(
            icon,
            color: primary,
            size: 21,
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 52,
          minHeight: maxLines > 1 ? 70 : 48,
        ),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 13,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red.shade300,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPreview() {
    final url = _logoController.text.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey.shade400,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Logo preview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This is how your store logo will appear.',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: const ValueKey('button'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isEditing
                          ? Icons.save_outlined
                          : Icons.add_business_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isEditing
                          ? 'Save Changes'
                          : 'Create Store',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}