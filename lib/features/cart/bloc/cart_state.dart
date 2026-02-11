import 'package:equatable/equatable.dart';
import 'package:restaurant_menu_app/features/cart/models/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object> get props => [items];
}
