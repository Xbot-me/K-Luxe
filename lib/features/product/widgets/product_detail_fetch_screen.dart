import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../product_detail_screen.dart';
import '../repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductDetailFetchScreen extends ConsumerStatefulWidget {
  final String id;
  const ProductDetailFetchScreen({super.key, required this.id});

  @override
  ConsumerState<ProductDetailFetchScreen> createState() => _ProductDetailFetchScreenState();
}

class _ProductDetailFetchScreenState extends ConsumerState<ProductDetailFetchScreen> {
  Product? _product;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(productRepositoryProvider).getProduct(widget.id).then((p) {
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