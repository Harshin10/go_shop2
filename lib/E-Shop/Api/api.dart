import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;
  bool isFavorite;
  int quantity;
  int totalamount;
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
    this.quantity = 1,
    this.totalamount=0,
    this.isFavorite = false,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'category': category,
      'thumbnail': thumbnail,
      'images': images,
      'isFavorite': isFavorite,
      'quantity': quantity,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      discountPercentage: json['discountPercentage'].toDouble(),
      rating: json['rating'].toDouble(),
      stock: json['stock'],
      brand: json['brand'],
      category: json['category'],
      thumbnail: json['thumbnail'],
      images: List<String>.from(json['images']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}

class Api {
 Future<List<Product>> getCategoryData(String category, {required String searchQuery}) async {
  int retryCount = 0;

  while (true) {
    try {
      final response = await http.get(Uri.parse("https://dummyjson.com/products/category/$category"));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

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
        print('Retrying after 1 seconds... Retry count: $retryCount');
        await Future.delayed(Duration(seconds: 1)); // Add an appropriate delay before retrying
      } else {
       
 retryCount++;
 await Future.delayed(Duration(seconds: 1));
      }
    } on http.ClientException catch (e) {
      print('HTTP Client Exception: $e');
      retryCount++;
    } catch (e) {
      print('Error: $e');
      retryCount++;
    
    }
  }
}
}
