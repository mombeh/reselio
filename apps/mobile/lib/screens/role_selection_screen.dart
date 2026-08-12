import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  final AuthService authService;

  const RoleSelectionScreen({
    super.key,
    required this.authService,
  });

  static const Color primary = Color(0xFF6C3FC5);
  static const Color background = Color(0xFFF9F7FC);
  static const Color textPrimary = Color(0xFF242029);
  static const Color textSecondary = Color(0xFF77727F);

  Future<void> _selectRole(
    BuildContext context,
    String role,
  ) async {
    try {
      await authService.updateRole(role);

      if (!context.mounted) return;

      if (role == 'customer') {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.customerHome,
          arguments: {
            'authService': authService,
          },
        );
      } else if (role == 'client') {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.clientHome,
          arguments: {
            'authService': authService,
          },
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.adminHome,
          arguments: {
            'authService': authService,
          },
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select role: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBrandIcon(),

              const SizedBox(height: 28),

              _buildHeader(),

              const SizedBox(height: 32),

              _RoleCard(
                title: 'Customer',
                subtitle: 'Browse and purchase products',
                description:
                    'Discover products, place orders and track your purchases.',
                icon: Icons.shopping_bag_outlined,
                color: const Color(0xFF2589EF),
                onTap: () => _selectRole(
                  context,
                  'customer',
                ),
              ),

              const SizedBox(height: 16),

              _RoleCard(
                title: 'Client',
                subtitle: 'Manage your business',
                description:
                    'Manage orders, customers, products and business performance.',
                icon: Icons.storefront_outlined,
                color: const Color(0xFF0D9D8C),
                onTap: () => _selectRole(
                  context,
                  'client',
                ),
              ),

              const SizedBox(height: 16),

              _RoleCard(
                title: 'Admin',
                subtitle: 'Manage the platform',
                description:
                    'Access system management and administrative features.',
                icon: Icons.admin_panel_settings_outlined,
                color: primary,
                onTap: () => _selectRole(
                  context,
                  'admin',
                ),
              ),

              const SizedBox(height: 28),

              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandIcon() {
    return Center(
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.manage_accounts_rounded,
          color: primary,
          size: 38,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How will you use Reselio?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Choose the role that best describes you. You can then access the features designed for your needs.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Select the role that matches how you want to use Reselio.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF242029),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Color(0xFF77727F),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: color,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}