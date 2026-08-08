import 'package:flutter/material.dart';
import 'package:mobile/models/notification_model.dart';
import 'package:mobile/services/auth_service.dart';

class NotificationScreen extends StatefulWidget {
  final AuthService? authService;

  const NotificationScreen({super.key, this.authService});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;
  bool _isRefreshing = false;

  AuthService? get _authService => widget.authService;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationsFuture = _authService?.apiService.getNotifications() ?? Future.value([]);
  }

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
      _loadNotifications();
    });
    await _notificationsFuture;
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _markAllRead() async {
    await _authService?.apiService.markAllNotificationsRead();
    _loadNotifications();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_outlined),
            onPressed: _isRefreshing ? null : _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.done_all_outlined),
            onPressed: _authService == null ? null : _markAllRead,
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () async {
                    if (!notification.isRead) {
                      await _authService?.apiService.markNotificationRead(notification.id);
                    }
                    _loadNotifications();
                    setState(() {});
                  },
                );
              },
            ),
          );
        },
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
    final type = notification.type;
    final isUnread = !notification.isRead;
    final color = type.color;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete_outlined, color: Colors.white),
      ),
      onDismissed: (_) {
        // Could implement delete notification via API
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        color: isUnread ? color.withValues(alpha: 0.08) : null,
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(type.icon, color: color, size: 20),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message),
              const SizedBox(height: 2),
              Text(
                notification.timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
