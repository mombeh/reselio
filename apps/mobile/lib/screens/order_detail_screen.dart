import 'package:flutter/material.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/services/auth_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final AuthService authService;
  final Order order;

  const OrderDetailScreen({
    super.key,
    required this.authService,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String _selectedStatus;
  bool _isUpdating = false;

  final Map<String, List<String>> _allowedTransitions = {
    'Pending': ['Confirmed', 'Preparing', 'Cancelled'],
    'Confirmed': [
      'Preparing',
      'Ready for Pickup',
      'Delivered',
      'Cancelled',
    ],
    'Preparing': ['Ready for Pickup', 'Delivered', 'Cancelled'],
    'Ready for Pickup': ['Delivered', 'Cancelled'],
    'Delivered': [],
    'Cancelled': [],
  };

  List<String> get _allowedStatuses =>
      _allowedTransitions[widget.order.status] ?? [];

  bool get _canUpdateStatus => _allowedStatuses.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'Preparing':
        return Colors.deepPurple;
      case 'Ready for Pickup':
        return Colors.teal;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule_rounded;
      case 'Confirmed':
        return Icons.check_circle_outline_rounded;
      case 'Preparing':
        return Icons.inventory_2_outlined;
      case 'Ready for Pickup':
        return Icons.shopping_bag_outlined;
      case 'Delivered':
        return Icons.local_shipping_outlined;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == widget.order.status) return;

    setState(() => _isUpdating = true);

    try {
      await widget.authService.apiService.updateOrderStatus(
        widget.order.id,
        _selectedStatus,
      );

      if (!mounted) return;

      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order status updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.authService.apiService.getErrorMessage(e),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cancel Order?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to cancel order '
            '${widget.order.orderNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep Order'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cancel Order'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isUpdating = true);

    try {
      await widget.authService.apiService.cancelOrder(widget.order.id);

      if (!mounted) return;

      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.authService.apiService.getErrorMessage(e),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final statusColor = _statusColor(order.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              order.orderNumber,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (order.status != 'Cancelled' &&
              order.status != 'Delivered')
            IconButton(
              tooltip: 'Cancel order',
              onPressed: _isUpdating ? null : _cancelOrder,
              icon: const Icon(
                Icons.more_vert_rounded,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _buildStatusHeader(
              order,
              statusColor,
            ),
            const SizedBox(height: 16),
            _buildCustomerCard(order),
            const SizedBox(height: 16),
            _buildItemsSection(order),
            const SizedBox(height: 16),
            _buildPaymentSummary(order),
            const SizedBox(height: 16),
            _buildOrderInformation(order),
            if (_canUpdateStatus) ...[
              const SizedBox(height: 24),
              _buildStatusUpdateSection(),
            ],
            if (order.status != 'Cancelled' &&
                order.status != 'Delivered') ...[
              const SizedBox(height: 16),
              _buildCancelButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(
    Order order,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _statusIcon(order.status),
                  color: statusColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _statusDescription(order.status),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildStatusProgress(order.status),
        ],
      ),
    );
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'Pending':
        return 'Waiting for confirmation';
      case 'Confirmed':
        return 'Order has been confirmed';
      case 'Preparing':
        return 'Order is being prepared';
      case 'Ready for Pickup':
        return 'Order is ready for pickup';
      case 'Delivered':
        return 'Order has been delivered';
      case 'Cancelled':
        return 'This order has been cancelled';
      default:
        return '';
    }
  }

  Widget _buildStatusProgress(String currentStatus) {
    const statuses = [
      'Pending',
      'Confirmed',
      'Preparing',
      'Ready for Pickup',
      'Delivered',
    ];

    if (currentStatus == 'Cancelled') {
      return Row(
        children: [
          Icon(
            Icons.cancel_rounded,
            color: Colors.red.shade600,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Order cancelled',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    final currentIndex = statuses.indexOf(currentStatus);

    return Row(
      children: List.generate(
        statuses.length * 2 - 1,
        (index) {
          if (index.isOdd) {
            final lineIndex = index ~/ 2;

            return Expanded(
              child: Container(
                height: 2,
                color: lineIndex < currentIndex
                    ? _statusColor(currentStatus)
                    : Colors.grey.shade300,
              ),
            );
          }

          final statusIndex = index ~/ 2;
          final isCompleted = statusIndex <= currentIndex;

          return Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? _statusColor(currentStatus)
                  : Colors.white,
              border: Border.all(
                color: isCompleted
                    ? _statusColor(currentStatus)
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 13,
                    color: Colors.white,
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildCustomerCard(Order order) {
    return _sectionCard(
      title: 'Customer',
      icon: Icons.person_outline_rounded,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerPhone,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(Order order) {
    return _sectionCard(
      title: 'Order Items',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        children: [
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProductImage(item.productImageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${item.quantity} × '
                          '${_formatCurrency(item.unitPrice)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatCurrency(item.totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 8),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} '
                '${order.items.length == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              Text(
                _formatCurrency(order.subtotal),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade400,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
       errorBuilder: (_, _, _) {
  return Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(
      Icons.image_not_supported_outlined,
      color: Colors.grey.shade400,
    ),
  );
},
      ),
    );
  }

  Widget _buildPaymentSummary(Order order) {
    return _sectionCard(
      title: 'Payment Summary',
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          _summaryRow(
            'Subtotal',
            _formatCurrency(order.subtotal),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Advance Paid',
            _formatCurrency(order.advancePaid),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          _summaryRow(
            'Total',
            _formatCurrency(order.total),
            isBold: true,
            fontSize: 18,
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Balance',
            _formatCurrency(order.balance),
            isBold: true,
            valueColor:
                order.balance > 0 ? Colors.orange : Colors.green,
          ),
          if (order.profit != 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: Colors.green.shade700,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Profit',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatCurrency(order.profit),
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 14,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInformation(Order order) {
    return _sectionCard(
      title: 'Order Information',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _infoRow(
            Icons.tag_rounded,
            'Order Number',
            order.orderNumber,
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.calendar_today_outlined,
            'Created',
            order.createdAt == null
                ? 'N/A'
                : '${_formatDate(order.createdAt)} '
                    '${_formatTime(order.createdAt)}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 19,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusUpdateSection() {
    return _sectionCard(
      title: 'Update Order Status',
      icon: Icons.sync_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'New Status',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: widget.order.status,
                child: Text(widget.order.status),
              ),
              ..._allowedStatuses.map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ),
              ),
            ],
            onChanged: _isUpdating
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _isUpdating ||
                      _selectedStatus == widget.order.status
                  ? null
                  : _updateStatus,
              icon: _isUpdating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(
                _isUpdating ? 'Updating...' : 'Update Status',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: _isUpdating ? null : _cancelOrder,
      icon: const Icon(Icons.cancel_outlined),
      label: const Text('Cancel Order'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade700,
        side: BorderSide(
          color: Colors.red.shade200,
        ),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}