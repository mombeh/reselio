import 'package:flutter/material.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/services/auth_service.dart';

class NotificationIconBadge extends StatefulWidget {
  final AuthService? authService;

  const NotificationIconBadge({super.key, this.authService});

  @override
  State<NotificationIconBadge> createState() => _NotificationIconBadgeState();
}

class _NotificationIconBadgeState extends State<NotificationIconBadge> {
  int _unreadCount = 0;
  bool _isLoading = false;

  Future<void> _fetchCount() async {
    if (widget.authService == null) return;
    setState(() => _isLoading = true);
    try {
      final count = await widget.authService!.apiService.getUnreadNotificationCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToNotifications() async {
    if (widget.authService == null) return;
    await Navigator.of(context).pushNamed(
      AppRouter.notifications,
      arguments: {'authService': widget.authService},
    );
    _fetchCount();
  }

  @override
  void initState() {
    super.initState();
    _fetchCount();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _unreadCount == 0) {
      return IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: _navigateToNotifications,
      );
    }

    return Badge(
      label: Text(_unreadCount > 99 ? '99+' : '$_unreadCount'),
      backgroundColor: Colors.red,
      textColor: Colors.white,
      child: IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: _navigateToNotifications,
      ),
    );
  }
}
