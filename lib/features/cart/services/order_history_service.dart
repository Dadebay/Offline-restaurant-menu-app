import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:restaurant_menu_app/features/cart/models/order.dart';

class OrderHistoryService {
  static const String _ordersKey = 'order_history';

  /// Get all orders
  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(_ordersKey);

    if (ordersJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(ordersJson);
      return decoded.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  /// Add a new order
  Future<bool> addOrder(Order order) async {
    try {
      final orders = await getOrders();
      orders.insert(0, order); // Add to beginning (most recent first)

      // Keep only last 100 orders to avoid data bloat
      if (orders.length > 100) {
        orders.removeRange(100, orders.length);
      }

      return await _saveOrders(orders);
    } catch (e) {
      print('Error adding order: $e');
      return false;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final orders = await getOrders();
      final index = orders.indexWhere((order) => order.id == orderId);

      if (index == -1) return false;

      orders[index] = orders[index].copyWith(status: newStatus);
      return await _saveOrders(orders);
    } catch (e) {
      print('Error updating order: $e');
      return false;
    }
  }

  /// Delete an order
  Future<bool> deleteOrder(String orderId) async {
    try {
      final orders = await getOrders();
      orders.removeWhere((order) => order.id == orderId);
      return await _saveOrders(orders);
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }

  /// Clear all order history
  Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_ordersKey);
    } catch (e) {
      print('Error clearing history: $e');
      return false;
    }
  }

  /// Save orders to SharedPreferences
  Future<bool> _saveOrders(List<Order> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = json.encode(orders.map((order) => order.toJson()).toList());
      return await prefs.setString(_ordersKey, ordersJson);
    } catch (e) {
      print('Error saving orders: $e');
      return false;
    }
  }

  /// Get orders by status
  Future<List<Order>> getOrdersByStatus(String status) async {
    final orders = await getOrders();
    return orders.where((order) => order.status == status).toList();
  }

  /// Get orders for today
  Future<List<Order>> getTodayOrders() async {
    final orders = await getOrders();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return orders.where((order) {
      final orderDate = DateTime(order.orderDate.year, order.orderDate.month, order.orderDate.day);
      return orderDate.isAtSameMomentAs(today);
    }).toList();
  }
}
