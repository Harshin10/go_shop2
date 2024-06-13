import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_shop/E-Shop/Api/apimodel.dart';



class API1 {
  Future<List<Product>> getCategoryData(String category, {required String searchQuery}) async {
    int retryCount = 0;

    final dio = Dio();

    while (true) {
      try {
        final response = await dio.get("https://dummyjson.com/products/category/$category");

        if (response.statusCode == 200) {
          Map<String, dynamic> data = response.data;

          if (data.containsKey('products')) {
            List<dynamic> productsData = data['products'];
            List<Product> products = productsData
                .map((productData) => Product.fromJson(productData))
                .toList();
            return products;
          } else {
            throw Exception('Key "products" not found in the response');
          }
        } else if (response.statusCode == 429) {
          retryCount++;
          print('Retrying after 1 second... Retry count: $retryCount');
        } else {
          retryCount++;
          print('Error: ${response.statusCode}');
        }
      } on DioError catch (e) {
        if (e.response?.statusCode == 429) {
          retryCount++;
          print('Retrying after 1 second... Retry count: $retryCount');
        } else {
          retryCount++;
          print('Dio Error: ${e.message}');
        }
      } catch (e) {
        print('Error: $e');
        retryCount++;
      }
    }
  }
}
class API2 {
Future<List<Product>> fetchData() async {
  final dio = Dio();
  final response = await dio.get('https://dummyjson.com/products');

  if (response.statusCode == 200) {
    List jsonResponse = response.data['products'];
    return jsonResponse.map((product) => Product.fromJson(product)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}
}

class SearchAPI extends ChangeNotifier {
  String query = '';
  List<Product> products = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  final _productStreamController = StreamController<List<Product>>.broadcast();
  Stream<List<Product>> get productStream => _productStreamController.stream;

  Future<void> fetchProducts(String query) async {
    int retryCount = 0;
    final dio = Dio();

    try {
      isLoading = true;
      hasError = false;
      clearProducts(); // Clear previous results
      notifyListeners();

      final response = await dio.get('https://dummyjson.com/products/search?q=$query');
      
      if (response.statusCode == 200) {
        final dynamic data = response.data;

        if (data is List) {
          products = data.map((productData) => Product.fromJson(productData)).toList();
        } else if (data is Map<String, dynamic>) {
          products = (data['products'] as List).map((productData) => Product.fromJson(productData)).toList();
        } else {
          throw Exception('Invalid JSON structure. Expected a List or Map.');
        }
        _productStreamController.add(products);
      } else {
        throw Exception('Failed to fetch products. Status code: ${response.statusCode}');
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 429) {
        retryCount++;
        print('Retrying after 1 second... Retry count: $retryCount');
        await Future.delayed(Duration(seconds: 1));
        return fetchProducts(query); // Retry fetching
      } else {
        hasError = true;
        errorMessage = 'Error fetching products: ${e.message}';
        print(errorMessage);
      }
    } catch (error) {
      hasError = true;
      errorMessage = 'Error fetching products: $error';
      print(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearProducts() {
    products = [];
    _productStreamController.add(products); // Update the stream with cleared products
    notifyListeners();
  }

  @override
  void dispose() {
    _productStreamController.close();
    super.dispose();
  }
}
class APIService {
  static final categoryProvider = FutureProvider<List<String>>((ref) async {
    final dio = Dio();
    final response = await dio.get('https://dummyjson.com/products/category-list');

    if (response.statusCode == 200) {
      return List<String>.from(response.data);
    } else {
      throw Exception('Failed to load categories');
    }
  });
    static Future<List<Product>> fetchProductsByCategory(String category) async {
    final dio = Dio();
    final response = await dio.get('https://dummyjson.com/products/category/$category');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products for category $category');
    }
  }
}