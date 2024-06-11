// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:go_shop/E-Shop/Api/apimodel.dart';


// import 'package:flutter/foundation.dart';

// class SearchAPI extends ChangeNotifier {
//   // Define your required properties
//   final StreamController<List<Product>> _productController = StreamController<List<Product>>();
//   bool isLoading = false;
//   bool hasError = false;
//   String errorMessage = '';

//   Stream<List<Product>> get productStream => _productController.stream;

//   void fetchProducts(String query) async {
//     // Implement your product fetching logic here
//     // For example, set loading state, fetch data, and add to stream
//     isLoading = true;
//     notifyListeners();

//     try {
//       // Simulate a network call
//       await Future.delayed(Duration(seconds: 2));
//       // Add fetched products to the stream
//       _productController.add(<Product>[]); // Replace with actual fetched data
//       isLoading = false;
//       hasError = false;
//     } catch (e) {
//       errorMessage = e.toString();
//       isLoading = false;
//       hasError = true;
//     }
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     _productController.close();
//     super.dispose();
//   }
// }
