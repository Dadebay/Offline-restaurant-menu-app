import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'package:restaurant_menu_app/features/cart/models/order.dart';
import 'package:restaurant_menu_app/features/cart/services/order_history_service.dart';
import 'package:restaurant_menu_app/features/language/bloc/language_bloc.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderHistoryService _orderHistoryService = OrderHistoryService();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _orderHistoryService.getOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  bool _isBase64(String path) => path.startsWith('data:image');
  bool _isLocalFile(String path) => path.startsWith('/') || path.startsWith('file://');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLang = context.watch<LanguageBloc>().state.locale.languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.translate('order_history'),
          style: const TextStyle(fontFamily: 'Gilroy', letterSpacing: 2, fontWeight: FontWeight.w900, color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [if (_orders.isNotEmpty) IconButton(icon: Icon(Icons.delete_sweep_outlined, color: theme.colorScheme.error), onPressed: () => _showClearHistoryDialog(context, theme))],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
              ? _buildEmptyHistory(context, theme)
              : RefreshIndicator(
                onRefresh: _loadOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _buildOrderCard(context, order, theme, currentLang);
                  },
                ),
              ),
    );
  }

  Widget _buildEmptyHistory(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.translate('no_orders'),
            style: TextStyle(fontFamily: 'Gilroy', color: Colors.white.withOpacity(0.5), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.translate('no_orders_msg'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Gilroy', color: Colors.white.withOpacity(0.3), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, ThemeData theme, String currentLang) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(dateFormat.format(order.orderDate), style: TextStyle(fontFamily: 'Gilroy', color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _getStatusColor(order.status).withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: _getStatusColor(order.status))),
                  child: Text(_getStatusText(order.status, context), style: TextStyle(fontFamily: 'Gilroy', color: _getStatusColor(order.status), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),

          Divider(color: Colors.white.withOpacity(0.05), height: 1),

          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: order.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Row(
                children: [
                  // Image
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 50, height: 50, child: _buildImage(item.menuItem.imageUrl))),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.menuItem.getName(currentLang),
                          style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text('${item.quantity} × ${item.menuItem.price} TMT', style: TextStyle(fontFamily: 'Gilroy', color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      ],
                    ),
                  ),
                  // Subtotal
                  Text('${item.totalPrice} TMT', style: TextStyle(fontFamily: 'Gilroy', color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              );
            },
          ),

          Divider(color: Colors.white.withOpacity(0.05), height: 1),

          // Total
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.translate('total'), style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${order.totalPrice} TMT', style: TextStyle(fontFamily: 'Gilroy', color: theme.colorScheme.primary, fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(color: Colors.grey.shade800, child: const Icon(Icons.fastfood, color: Colors.grey));
    }
    if (_isBase64(imageUrl)) {
      try {
        return Image.memory(base64Decode(imageUrl.split(',').last), fit: BoxFit.cover);
      } catch (_) {
        return const Icon(Icons.error, color: Colors.grey);
      }
    }
    if (_isLocalFile(imageUrl)) {
      return Image.file(File(imageUrl), fit: BoxFit.cover);
    }
    return Image.network(imageUrl, fit: BoxFit.cover);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  String _getStatusText(String status, BuildContext context) {
    switch (status) {
      case 'pending':
        return AppLocalizations.of(context)!.translate('pending');
      case 'preparing':
        return AppLocalizations.of(context)!.translate('preparing');
      case 'ready':
        return AppLocalizations.of(context)!.translate('ready');
      case 'completed':
        return AppLocalizations.of(context)!.translate('completed');
      default:
        return status;
    }
  }

  void _showClearHistoryDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(AppLocalizations.of(context)!.translate('clear_history'), style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontWeight: FontWeight.bold)),
            content: Text(AppLocalizations.of(context)!.translate('clear_history_msg'), style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.translate('cancel'), style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white70))),
              TextButton(
                onPressed: () async {
                  await _orderHistoryService.clearHistory();
                  Navigator.pop(context);
                  _loadOrders();
                },
                child: Text(AppLocalizations.of(context)!.translate('clear'), style: TextStyle(fontFamily: 'Gilroy', color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
    );
  }
}
