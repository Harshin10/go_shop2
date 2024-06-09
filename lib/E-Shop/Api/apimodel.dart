// class Product {
//   final int id;
//   final String title;
//   final String description;
//   final double price;
//   final double discountPercentage;
//   final double rating;
//   final int stock;
//   final String brand;
//   final String category;
//   final String thumbnail;
//   final List<String> images;
//   bool isFavorite;
//   int quantity;
//   int totalamount;
//   Product({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.price,
//     required this.discountPercentage,
//     required this.rating,
//     required this.stock,
//     required this.brand,
//     required this.category,
//     required this.thumbnail,
//     required this.images,
//     this.quantity = 1,
//     this.totalamount=0,
//     this.isFavorite = false,
//   });
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'price': price,
//       'discountPercentage': discountPercentage,
//       'rating': rating,
//       'stock': stock,
//       'brand': brand,
//       'category': category,
//       'thumbnail': thumbnail,
//       'images': images,
//       'isFavorite': isFavorite,
//       'quantity': quantity,
//     };
//   }

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'],
//       title: json['title'],
//       description: json['description'],
//       price: json['price'].toDouble(),
//       discountPercentage: json['discountPercentage'].toDouble(),
//       rating: json['rating'].toDouble(),
//       stock: json['stock'],
//       brand: json['brand'],
//       category: json['category'],
//       thumbnail: json['thumbnail'],
//       images: List<String>.from(json['images']),
//       isFavorite: json['isFavorite'] ?? false,
//     );
//   }
// }
import 'package:flutter/material.dart';

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
    this.totalamount = 0,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      stock: json['stock'] ?? 0,
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      quantity: json['quantity'] ?? 1,
      totalamount: json['totalamount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
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
      'quantity': quantity,
      'totalamount': totalamount,
      'isFavorite': isFavorite,
    };
  }
}

class Categories {
  String title;
  String imageUrl;
  BoxFit fit;

  Categories({
    required this.title,
    required this.imageUrl,
    this.fit = BoxFit.fill,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      fit: BoxFit.fill,
    );
  }
}
