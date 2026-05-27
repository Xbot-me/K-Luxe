import 'package:flutter/material.dart';
import '../product_detail_screen.dart';
import '../repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductDetailFetchScreen extends StatefulWidget {
  final String id;
  const ProductDetailFetchScreen({super.key, required this.id});

  @override
  State<ProductDetailFetchScreen> createState() => _ProductDetailFetchScreenState();
}

class _ProductDetailFetchScreenState extends State<ProductDetailFetchScreen> {
  Product? _product;
  String? _error;

  @override
  void initState() {
    super.initState();
    ProductRepository.instance.getProduct(widget.id).then((p) {
      if (mounted) setState(() => _product = p);
    }).catchError((e) {
      if (mounted) setState(() => _error = 'Product not found');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.white))),
      );
    }
    if (_product == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return ProductDetailScreen(product: _product!);
  }
}