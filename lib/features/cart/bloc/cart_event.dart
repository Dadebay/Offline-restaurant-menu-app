import 'package:equatable/equatable.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddCartItem extends CartEvent {
  final MenuItem item;
  const AddCartItem(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveCartItem extends CartEvent {
  final MenuItem item;
  const RemoveCartItem(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateCartItemQuantity extends CartEvent {
  final MenuItem item;
  final int quantity;
  const UpdateCartItemQuantity(this.item, this.quantity);

  @override
  List<Object> get props => [item, quantity];
}

class ClearCart extends CartEvent {}
