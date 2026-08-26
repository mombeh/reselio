import 'package:flutter/material.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/services/auth_service.dart';

class AdminHome extends StatefulWidget {
  final AuthService authService;

  const AdminHome({
    super.key,
    required this.authService,
  });

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  static const Color primary = Color(0xFF6C4AB6);
  static const Color background = Color(0xFFF7F7FA);
  static const Color textDark = Color(0xFF202027);
  static const Color textMuted = Color(0xFF777780);

  static const Color success = Color(0xFF2E9B68);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2589EF);
  static const Color danger = Color(0xFFE05252);
  static const Color teal = Color(0xFF0D9D8C);

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    _dashboardFuture =
        widget.authService.apiService.getAdminDashboard();
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture =
          widget.authService.apiService.getAdminDashboard();
    });

    await _dashboardFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: RefreshIndicator(
          color: primary,
          onRefresh: _refresh,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.data == null) {
                return _buildLoadingSkeleton();
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error);
              }

              final data = snapshot.data ?? {};

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  40,
                ),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildWelcomeBanner(data),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    title: 'Platform Overview',
                    subtitle: 'Key statistics across Reselio',
                  ),
                  const SizedBox(height: 14),
                  _buildMetricGrid(data),
                  const SizedBox(height: 24),
                  _buildRevenueCard(data),
                  const SizedBox(height: 24),
                  _buildOrdersOverview(data),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    title: 'Management',
                    subtitle: 'Quick access to platform resources',
                  ),
                  const SizedBox(height: 14),
                  _buildManagementGrid(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    final user = widget.authService.currentUser;

    final name = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'Administrator';

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                primary,
                Color(0xFF8A6BC5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.20),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontSize: 12,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ],
          ),
        ),
        _headerAction(
          icon: Icons.refresh_rounded,
          onTap: _refresh,
        ),
        const SizedBox(width: 8),
        _headerAction(
          icon: Icons.logout_rounded,
          onTap: _confirmLogout,
        ),
      ],
    );
  }

  Widget _headerAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFECEAF0),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: textDark,
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  // ---------------------------------------------------------------------------
  // WELCOME BANNER
  // ---------------------------------------------------------------------------

  Widget _buildWelcomeBanner(Map<String, dynamic> data) {
    final sellers = _number(data['totalSellers']);
    final customers = _number(data['totalCustomers']);
    final products = _number(data['totalProducts']);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C4AB6),
            Color(0xFF8060C3),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reselio Admin',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.80),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Manage your platform',
                      style: TextStyle(
                        fontSize: 23,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.dashboard_customize_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _bannerStat(
                value: sellers,
                label: 'Sellers',
              ),
              _bannerDivider(),
              _bannerStat(
                value: customers,
                label: 'Customers',
              ),
              _bannerDivider(),
              _bannerStat(
                value: products,
                label: 'Products',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerStat({
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerDivider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: textMuted,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // METRICS
  // ---------------------------------------------------------------------------

  Widget _buildMetricGrid(Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _metricCard(
          title: 'Total Sellers',
          value: _number(data['totalSellers']),
          icon: Icons.storefront_rounded,
          color: primary,
        ),
        _metricCard(
          title: 'Total Customers',
          value: _number(data['totalCustomers']),
          icon: Icons.people_alt_rounded,
          color: info,
        ),
        _metricCard(
          title: 'Total Products',
          value: _number(data['totalProducts']),
          icon: Icons.inventory_2_rounded,
          color: success,
        ),
        _metricCard(
          title: 'Total Orders',
          value: _number(data['totalOrders']),
          icon: Icons.shopping_bag_rounded,
          color: warning,
        ),
        _metricCard(
          title: 'Pending Orders',
          value: _number(data['pendingOrders']),
          icon: Icons.pending_actions_rounded,
          color: danger,
        ),
        _metricCard(
          title: 'Active Users',
          value: _number(data['activeUsers']),
          icon: Icons.person_rounded,
          color: teal,
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFECEAF0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REVENUE
  // ---------------------------------------------------------------------------

  Widget _buildRevenueCard(Map<String, dynamic> data) {
    final revenue = _numberValue(data['totalRevenue']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFECEAF0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: success,
              size: 26,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatCurrency(revenue)} FCFA',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: success.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: success,
                  size: 15,
                ),
                SizedBox(width: 4),
                Text(
                  'Revenue',
                  style: TextStyle(
                    color: success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ORDERS OVERVIEW
  // ---------------------------------------------------------------------------

  Widget _buildOrdersOverview(Map<String, dynamic> data) {
    final totalOrders = _numberValue(data['totalOrders']);
    final pendingOrders = _numberValue(data['pendingOrders']);

    final completedOrders =
        totalOrders > pendingOrders
            ? totalOrders - pendingOrders
            : 0;

    final pendingPercentage = totalOrders > 0
        ? (pendingOrders / totalOrders).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFECEAF0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orders Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Current platform order status',
                      style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: warning.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: warning,
                  size: 19,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _orderStatus(
                  label: 'Total',
                  value: totalOrders.toStringAsFixed(0),
                  color: info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _orderStatus(
                  label: 'Pending',
                  value: pendingOrders.toStringAsFixed(0),
                  color: warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _orderStatus(
                  label: 'Others',
                  value: completedOrders.toStringAsFixed(0),
                  color: success,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: pendingPercentage,
              backgroundColor: const Color(0xFFF0EEF3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                warning,
              ),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pending order ratio',
                style: TextStyle(
                  fontSize: 11,
                  color: textMuted,
                ),
              ),
              Text(
                '${(pendingPercentage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderStatus({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MANAGEMENT
  // ---------------------------------------------------------------------------

  Widget _buildManagementGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _managementCard(
          title: 'Sellers',
          subtitle: 'Manage sellers',
          icon: Icons.storefront_rounded,
          color: primary,
          onTap: () => _openRoute(AppRouter.sellerList),
        ),
        _managementCard(
          title: 'Products',
          subtitle: 'View products',
          icon: Icons.inventory_2_rounded,
          color: success,
          onTap: () => _openRoute(AppRouter.adminProductList),
        ),
        _managementCard(
          title: 'Orders',
          subtitle: 'Manage orders',
          icon: Icons.receipt_long_rounded,
          color: warning,
          onTap: () => _openRoute(AppRouter.adminOrderList),
        ),
        _managementCard(
          title: 'Customers',
          subtitle: 'View customers',
          icon: Icons.people_alt_rounded,
          color: info,
          onTap: () => _openRoute(AppRouter.adminCustomerList),
        ),
        _managementCard(
          title: 'Reports',
          subtitle: 'Platform analytics',
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () => _openRoute(AppRouter.adminReports),
        ),
      ],
    );
  }

  Widget _managementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFECEAF0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------------------------

  void _openRoute(String route) {
    Navigator.pushNamed(
      context,
      route,
      arguments: {
        'authService': widget.authService,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from your Reselio admin account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: danger,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await widget.authService.logout();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRouter.login,
      arguments: {
        'authService': widget.authService,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // LOADING
  // ---------------------------------------------------------------------------

  Widget _buildLoadingSkeleton() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
      children: [
        Row(
          children: [
            _skeletonBox(
              width: 48,
              height: 48,
              radius: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _skeletonBox(
                width: double.infinity,
                height: 45,
                radius: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _skeletonBox(
          width: double.infinity,
          height: 170,
          radius: 24,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _skeletonBox(
                width: double.infinity,
                height: 145,
                radius: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _skeletonBox(
                width: double.infinity,
                height: 145,
                radius: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _skeletonBox(
                width: double.infinity,
                height: 145,
                radius: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _skeletonBox(
                width: double.infinity,
                height: 145,
                radius: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _skeletonBox(
          width: double.infinity,
          height: 100,
          radius: 22,
        ),
      ],
    );
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------

  Widget _buildErrorState(Object? error) {
    String message;

    try {
      message =
          widget.authService.apiService.getErrorMessage(error);
    } catch (_) {
      message = 'Unable to load the admin dashboard.';
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 100),
          decoration: BoxDecoration(
            color: danger.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_off_rounded,
            color: danger,
            size: 38,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Couldn\'t load dashboard',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: textMuted,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  String _number(dynamic value) {
    if (value == null) return '0';

    if (value is num) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  double _numberValue(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    }

    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }

    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }

    return amount.toStringAsFixed(0);
  }
}