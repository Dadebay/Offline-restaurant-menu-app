import 'package:equatable/equatable.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';

class CartItem extends Equatable {
  final MenuItem menuItem;
  final int quantity;

  const CartItem({required this.menuItem, required this.quantity});

  CartItem copyWith({MenuItem? menuItem, int? quantity}) {
    return CartItem(menuItem: menuItem ?? this.menuItem, quantity: quantity ?? this.quantity);
  }

  double get totalPrice => menuItem.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(menuItem: MenuItem.fromJson(json['menuItem'] as Map<String, dynamic>), quantity: json['quantity'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'menuItem': menuItem.toJson(), 'quantity': quantity};
  }

  @override
  List<Object?> get props => [menuItem, quantity];
}
