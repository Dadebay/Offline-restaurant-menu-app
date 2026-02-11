import 'package:equatable/equatable.dart';
import 'package:restaurant_menu_app/features/cart/models/cart_item.dart';

class Order extends Equatable {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime orderDate;
  final String status; // 'pending', 'preparing', 'ready', 'completed'

  const Order({required this.id, required this.items, required this.totalPrice, required this.orderDate, this.status = 'pending'});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List).map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      orderDate: DateTime.parse(json['orderDate'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'items': items.map((item) => item.toJson()).toList(), 'totalPrice': totalPrice, 'orderDate': orderDate.toIso8601String(), 'status': status};
  }

  Order copyWith({String? id, List<CartItem>? items, double? totalPrice, DateTime? orderDate, String? status}) {
    return Order(id: id ?? this.id, items: items ?? this.items, totalPrice: totalPrice ?? this.totalPrice, orderDate: orderDate ?? this.orderDate, status: status ?? this.status);
  }

  @override
  List<Object?> get props => [id, items, totalPrice, orderDate, status];
}
