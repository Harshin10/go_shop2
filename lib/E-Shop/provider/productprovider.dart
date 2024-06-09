import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_shop/E-Shop/Api/api.dart';
import 'package:go_shop/E-Shop/Api/apimodel.dart';

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super([]) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final api = API2(); 
    final products = await api.fetchData();
    state = products;
  }
}



