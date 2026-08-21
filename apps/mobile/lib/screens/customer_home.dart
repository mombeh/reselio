import 'package:flutter/material.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/screens/customer_product_list_screen.dart';
import 'package:mobile/screens/my_products_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/notification_icon_badge.dart';

class CustomerHome extends StatefulWidget {
  final AuthService authService;

  const CustomerHome({super.key, required this.authService});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isLoadingDashboard = true;

  int _ordersCount = 0;
  int _favoritesCount = 0;
  int _unreadNotifications = 0;
  List<Order> _recentOrders = [];
  List<Product> _featuredProducts = [];

  late final List<Widget> _pages;

  static const Color primary = Color(0xFF6C4AB6);
  static const Color background = Color(0xFFF7F7FA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pages = [
      _buildDashboardPage(),
      MyProductsScreen(authService: widget.authService),
      CustomerProductListScreen(authService: widget.authService),
      const SizedBox.shrink(),
    ];
    _loadDashboardData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDashboardData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoadingDashboard = true;
    });

    try {
      final results = await Future.wait([
        widget.authService.apiService.getMyOrders(page: 1, limit: 5),
        widget.authService.apiService.getFavorites(),
        widget.authService.apiService.getUnreadNotificationCount(),
        widget.authService.apiService.getPublicProducts(),
      ]);

      if (!mounted) return;

      final ordersResult = results[0] as Map<String, dynamic>;
      final favorites = results[1] as List;
      final unreadCount = results[2] as int;
      final products = results[3] as List<Product>;

      setState(() {
        _ordersCount = ordersResult['total'] as int? ?? 0;
        _favoritesCount = favorites.length;
        _unreadNotifications = unreadCount;
        _recentOrders = (ordersResult['data'] as List<Order>? ?? []).take(3).toList();
        _featuredProducts = products.take(8).toList();
        _isLoadingDashboard = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDashboard = false;
      });
    }
  }

  Widget _buildDashboardPage() {
    return RefreshIndicator(
      color: primary,
      onRefresh: _loadDashboardData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildFeaturedProducts(),
          if (_recentOrders.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildRecentOrders(),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final user = widget.authService.currentUser;
    final name = user?.name.trim().isNotEmpty == true ? user!.name.trim() : 'Guest';
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome to Reselio',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          NotificationIconBadge(authService: widget.authService),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(
          label: 'Orders',
          value: _ordersCount.toString(),
          icon: Icons.shopping_bag_outlined,
          color: Colors.blue,
          onTap: () => _navigateTo(AppRouter.myProducts),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Favorites',
          value: _favoritesCount.toString(),
          icon: Icons.favorite_outlined,
          color: Colors.red,
          onTap: () => _navigateTo(AppRouter.favorites),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Notifications',
          value: _unreadNotifications.toString(),
          icon: Icons.notifications_outlined,
          color: Colors.orange,
          onTap: () => _navigateTo(AppRouter.notifications),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF202027),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Browse Products',
                subtitle: 'Explore all products',
                icon: Icons.search_rounded,
                color: Colors.green,
                onTap: () => _navigateTo(AppRouter.customerProductList),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'My Orders',
                subtitle: 'View order history',
                icon: Icons.receipt_long_outlined,
                color: Colors.blue,
                onTap: () => _navigateTo(AppRouter.myProducts),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Favorites',
                subtitle: 'Saved products',
                icon: Icons.favorite_rounded,
                color: Colors.red,
                onTap: () => _navigateTo(AppRouter.favorites),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'Notifications',
                subtitle: 'Updates & alerts',
                icon: Icons.notifications_rounded,
                color: Colors.orange,
                onTap: () => _navigateTo(AppRouter.notifications),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF202027),
              ),
            ),
            TextButton.icon(
              onPressed: () => _navigateTo(AppRouter.customerProductList),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingDashboard)
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => const _ProductSkeleton(),
            ),
          )
        else if (_featuredProducts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Color(0xFF6C4AB6)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No products available yet. Check back later!',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredProducts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = _featuredProducts[index];
                return _ProductCard(
                  product: product,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRouter.productDetail,
                      arguments: {
                        'authService': widget.authService,
                        'product': product,
                      },
                    );
                    if (mounted) {
                      _loadDashboardData();
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF202027),
              ),
            ),
            TextButton.icon(
              onPressed: () => _navigateTo(AppRouter.myProducts),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _recentOrders.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final order = _recentOrders[index];
            return _RecentOrderCard(
              order: order,
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  AppRouter.orderDetail,
                  arguments: {
                    'authService': widget.authService,
                    'order': order,
                  },
                );
                if (mounted) {
                  _loadDashboardData();
                }
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _navigateTo(String route) async {
    await Navigator.pushNamed(context, route, arguments: {'authService': widget.authService});
    if (mounted) {
      _loadDashboardData();
    }
  }

  void _onNavigationTap(int index) {
    if (index == 3) {
      _showMoreMenu();
      return;
    }

    if (index == 1) {
      Navigator.pushNamed(
        context,
        AppRouter.myProducts,
        arguments: {'authService': widget.authService},
      ).then((_) {
        if (mounted) _loadDashboardData();
      });
      return;
    }

    if (index == 2) {
      Navigator.pushNamed(
        context,
        AppRouter.customerProductList,
        arguments: {'authService': widget.authService},
      ).then((_) {
        if (mounted) _loadDashboardData();
      });
      return;
    }

    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _showMoreMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _MoreMenu(
          authService: widget.authService,
          onRefresh: _loadDashboardData,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              _navItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _navItem(
                index: 1,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Orders',
              ),
              _navItem(
                index: 2,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2_rounded,
                label: 'Products',
              ),
              _navItem(
                index: 3,
                icon: Icons.more_horiz_rounded,
                activeIcon: Icons.more_horiz_rounded,
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavigationTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? primary.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? primary : const Color(0xFF777780),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? primary : const Color(0xFF777780),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFECEAF0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202027),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF777780),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFECEAF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202027),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFECEAF0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EDF5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                clipBehavior: Clip.antiAlias,
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, _, _) => const _ImagePlaceholder(),
                      )
                    : const _ImagePlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202027),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(product.price),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6C4AB6),
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

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K FCFA';
    }
    return '${amount.toStringAsFixed(0)} FCFA';
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 24,
        color: Color(0xFF9A8CAF),
      ),
    );
  }
}

class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E7EC),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _RecentOrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECEAF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE8F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF6C4AB6),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202027),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Confirmed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}

class _MoreMenu extends StatelessWidget {
  final AuthService authService;
  final VoidCallback? onRefresh;

  const _MoreMenu({required this.authService, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _MenuItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                color: Colors.deepPurple,
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.pushNamed(
                    context,
                    AppRouter.profile,
                    arguments: {'authService': authService},
                  );
                  onRefresh?.call();
                },
              ),
              const SizedBox(height: 12),
              _MenuItem(
                icon: Icons.favorite_outlined,
                label: 'Favorites',
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.pushNamed(
                    context,
                    AppRouter.favorites,
                    arguments: {'authService': authService},
                  );
                  onRefresh?.call();
                },
              ),
              const SizedBox(height: 12),
              _MenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                color: Colors.orange,
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.pushNamed(
                    context,
                    AppRouter.notifications,
                    arguments: {'authService': authService},
                  );
                  onRefresh?.call();
                },
              ),
              const SizedBox(height: 12),
              _MenuItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: Colors.red,
                onTap: () async {
                  final navigator = Navigator.of(context);
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
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
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

                  if (confirmed != true) return;

                  await authService.logout();
                  if (!context.mounted) return;
                  navigator.pushReplacementNamed(
                    AppRouter.login,
                    arguments: {'authService': authService},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202027),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
