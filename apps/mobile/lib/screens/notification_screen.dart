import 'package:flutter/material.dart';
import 'package:mobile/models/notification_model.dart';
import 'package:mobile/services/auth_service.dart';

class NotificationScreen extends StatefulWidget {
  final AuthService? authService;

  const NotificationScreen({
    super.key,
    this.authService,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List> _notificationsFuture;
  bool _isRefreshing = false;
  bool _isMarkingAllRead = false;

  AuthService? get _authService => widget.authService;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationsFuture =
        _authService?.apiService.getNotifications() ?? Future.value([]);
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _loadNotifications();
    });

    try {
      await _notificationsFuture;
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _markAllRead() async {
    if (_authService == null || _isMarkingAllRead) return;

    setState(() {
      _isMarkingAllRead = true;
    });

    try {
      await _authService!.apiService.markAllNotificationsRead();

      if (!mounted) return;

      _loadNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _authService!.apiService.getErrorMessage(e),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAllRead = false;
        });
      }
    }
  }

  Future<void> _handleNotificationTap(
    NotificationModel notification,
  ) async {
    if (!notification.isRead && _authService != null) {
      try {
        await _authService!.apiService.markNotificationRead(
          notification.id,
        );
      } catch (_) {
        // Keep the notification screen usable even if marking as read fails.
      }
    }

    if (!mounted) return;

    setState(() {
      _loadNotifications();
    });
  }

  int _unreadCount(List notifications) {
    return notifications.where((item) {
      final notification = item as NotificationModel;
      return !notification.isRead;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_outlined),
              onPressed: _refresh,
            ),
          if (_authService != null)
            IconButton(
              tooltip: 'Mark all as read',
              icon: _isMarkingAllRead
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.done_all_outlined),
              onPressed: _isMarkingAllRead ? null : _markAllRead,
            ),
        ],
      ),
      body: FutureBuilder<List>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }

          final notifications = snapshot.data ?? [];
          final unreadCount = _unreadCount(notifications);

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _buildHeaderSummary(
                  total: notifications.length,
                  unread: unreadCount,
                ),
                const SizedBox(height: 20),
                ...notifications.map(
                  (item) {
                    final notification = item as NotificationModel;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NotificationTile(
                        notification: notification,
                        onTap: () => _handleNotificationTap(notification),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSummary({
    required int total,
    required int unread,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your notifications',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unread == 0
                      ? 'You are all caught up.'
                      : '$unread unread ${unread == 1 ? 'notification' : 'notifications'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unread',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _loadingBox(
          height: 82,
          radius: 20,
        ),
        const SizedBox(height: 20),
        _notificationSkeleton(),
        _notificationSkeleton(),
        _notificationSkeleton(),
        _notificationSkeleton(),
      ],
    );
  }

  Widget _loadingBox({
    required double height,
    required double radius,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _notificationSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      height: 94,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No notifications yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You will see updates about your orders, customers, and business here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    final message = _authService != null
        ? _authService!.apiService.getErrorMessage(error)
        : 'Unable to load notifications.';

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 42,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Couldn\'t load notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = notification.type;
    final isUnread = !notification.isRead;
    final color = type.color;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        // Delete functionality can be connected once
        // a delete-notification API method is available.
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnread
                  ? color.withValues(alpha: 0.07)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isUnread
                    ? color.withValues(alpha: 0.20)
                    : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isUnread ? 0.04 : 0.02,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        notification.type.icon,
        color: color,
        size: 22,
      ),
    );
  }
}