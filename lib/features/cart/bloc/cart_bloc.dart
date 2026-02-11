import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_menu_app/features/cart/models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddCartItem>(_onAddItem);
    on<RemoveCartItem>(_onRemoveItem);
    on<UpdateCartItemQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddItem(AddCartItem event, Emitter<CartState> emit) {
    final existingIndex = state.items.indexWhere(
      (i) => i.menuItem.id == event.item.id,
    );
    final List<CartItem> updatedList = List.from(state.items);

    if (existingIndex >= 0) {
      final existingItem = updatedList[existingIndex];
      updatedList[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      updatedList.add(CartItem(menuItem: event.item, quantity: 1));
    }

    emit(state.copyWith(items: updatedList));
  }

  void _onRemoveItem(RemoveCartItem event, Emitter<CartState> emit) {
    final updatedList =
        state.items.where((i) => i.menuItem.id != event.item.id).toList();
    emit(state.copyWith(items: updatedList));
  }

  void _onUpdateQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) {
    if (event.quantity <= 0) {
      add(RemoveCartItem(event.item));
      return;
    }

    final existingIndex = state.items.indexWhere(
      (i) => i.menuItem.id == event.item.id,
    );
    if (existingIndex >= 0) {
      final List<CartItem> updatedList = List.from(state.items);
      updatedList[existingIndex] = updatedList[existingIndex].copyWith(
        quantity: event.quantity,
      );
      emit(state.copyWith(items: updatedList));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState(items: []));
  }
}
