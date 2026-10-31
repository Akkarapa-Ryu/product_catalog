import 'package:flutter_riverpod/flutter_riverpod.dart';

// เก็บสินค้าและจำนวนสินค้าในตะกร้า
final cartProvider = StateProvider<Map<int, int>>((ref) {
  return {};
});

// คำนวณจำนวนสินค้ารวมทั้งหมด
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);

  return cart.values.fold(
    0,
    (total, quantity) => total + quantity,
  );
});