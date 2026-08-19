import 'package:flutter/material.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/edit_profile_dialog.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService authService;

  const ProfileScreen({
    super.key,
    required this.authService,
  });

  Future<void> _logout(BuildContext context) async {
    await authService.logout();

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRouter.login,
      arguments: {
        'authService': authService,
      },
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final user = authService.currentUser;

    await showDialog(
      context: context,
      builder: (context) {
        return EditProfileDialog(
          user: user,
          authService: authService,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = authService.currentUser;

    final name = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'User';

    final email = user?.email ?? '';
    final role = user?.role ?? 'customer';
    final isCustomer = role == 'customer';

    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editProfile(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            // ----------------------------------------------------------
            // PROFILE HEADER
            // ----------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      _capitalize(role),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  if (!isCustomer && user?.businessName != null && user!.businessName!.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            user.businessName!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Edit profile button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _editProfile(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ----------------------------------------------------------
            // ACCOUNT INFORMATION
            // ----------------------------------------------------------
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              context: context,
              icon: Icons.person_outline,
              iconColor: Colors.deepPurple,
              title: 'Full Name',
              value: name,
            ),

            _buildInfoCard(
              context: context,
              icon: Icons.email_outlined,
              iconColor: Colors.blue,
              title: 'Email',
              value: email.isNotEmpty ? email : 'Not provided',
            ),

            if (user?.phone != null &&
                user!.phone!.trim().isNotEmpty)
              _buildInfoCard(
                context: context,
                icon: Icons.phone_outlined,
                iconColor: Colors.green,
                title: 'Phone Number',
                value: user.phone!,
              ),

            if (!isCustomer && user?.address != null &&
                user!.address!.trim().isNotEmpty)
              _buildInfoCard(
                context: context,
                icon: Icons.location_on_outlined,
                iconColor: Colors.red,
                title: 'Address',
                value: user.address!,
              ),

            if (!isCustomer) ...[
              const SizedBox(height: 20),

              // ----------------------------------------------------------
              // BUSINESS INFORMATION
              // ----------------------------------------------------------
              const Text(
                'Business Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              if (user?.businessName != null &&
                  user!.businessName!.trim().isNotEmpty)
                _buildInfoCard(
                  context: context,
                  icon: Icons.store_outlined,
                  iconColor: Colors.orange,
                  title: 'Store Name',
                  value: user.businessName!,
                ),

              _buildInfoCard(
                context: context,
                icon: Icons.badge_outlined,
                iconColor: Colors.indigo,
                title: 'Account Role',
                value: _capitalize(role),
              ),

              if (user?.currency != null &&
                  user!.currency!.trim().isNotEmpty)
                _buildInfoCard(
                  context: context,
                  icon: Icons.payments_outlined,
                  iconColor: Colors.teal,
                  title: 'Currency',
                  value: user.currency!,
                ),
            ],

            const SizedBox(height: 28),

            // ----------------------------------------------------------
            // LOGOUT
            // ----------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.logout_outlined,
                          color: Colors.red,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign out',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Sign out of your Reselio account',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutConfirmation(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from your Reselio account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _logout(context);
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() + value.substring(1);
  }
}