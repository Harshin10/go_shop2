import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:go_shop/E-Shop/Api/api.dart';

class SearchScreenController extends ChangeNotifier {
  String query = '';
  List<Product> products = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  final _productStreamController = StreamController<List<Product>>.broadcast();
  Stream<List<Product>> get productStream => _productStreamController.stream;
  Future<void> fetchProducts(String query) async {
    try {
      isLoading = true;
      hasError = false;
      clearProducts(); // Clear previous results
      notifyListeners();

      final response = await http
          .get(Uri.parse('https://dummyjson.com/products/search?q=$query'));
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is List) {
          // If data is a List, directly assign it to products
          products =
              data.map((productData) => Product.fromJson(productData)).toList();
        } else if (data is Map<String, dynamic>) {
          // If data is a Map, extract the list from the Map
          products = (data['products'] as List)
              .map((productData) => Product.fromJson(productData))
              .toList();
        } else {
          throw Exception('Invalid JSON structure. Expected a List or Map.');
        }
        _productStreamController.add(products);
      } else {
        throw Exception(
            'Failed to fetch products. Status code: ${response.statusCode}');
      }
    } catch (error) {
      hasError = true;
      errorMessage = 'Error fetching products: $error';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearProducts() {
    products = [];
    notifyListeners();
  }
}
