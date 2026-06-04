import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/services/demo_stock_storage.dart';
import '../../domain/models/product.dart';
import '../../domain/models/stock_movement.dart';
import '../../providers/app_providers.dart';

class MovementsScreen extends ConsumerStatefulWidget {
  const MovementsScreen({super.key});

  @override
  ConsumerState<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends ConsumerState<MovementsScreen> {
  final _quantity = TextEditingController(text: '1');
  MovementType _type = MovementType.entry;
  Product? _selectedProduct;
  var _isSaving = false;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _saveMovement() async {
    final product = _selectedProduct;
    final quantity = int.tryParse(_quantity.text);
    if (product == null || quantity == null || quantity <= 0) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final firebaseReady = ref.read(firebaseReadyProvider);
      if (firebaseReady) {
        await ref
            .read(stockRepositoryProvider)
            .addMovement(
              clientId: ref.read(clientIdProvider),
              product: product,
              type: _type,
              quantity: quantity,
            );
      } else {
        _saveDemoMovement(product, quantity);
      }
      _quantity.text = '1';
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _saveDemoMovement(Product product, int quantity) {
    final delta = _type == MovementType.entry ? quantity : -quantity;
    final nextQuantity = product.quantity + delta;

    if (nextQuantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock insuffisant pour cette vente.')),
      );
      return;
    }

    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      quantity: nextQuantity,
      threshold: product.threshold,
      unitPrice: product.unitPrice,
      createdAt: product.createdAt,
    );

    final products = ref
        .read(demoProductsProvider)
        .map((item) => item.id == product.id ? updatedProduct : item)
        .toList();
    ref.read(demoProductsProvider.notifier).state = products;
    DemoStockStorage.saveProducts(
      ref.read(sharedPreferencesProvider),
      products,
    );

    final movement = StockMovement(
      id: 'mov-${DateTime.now().microsecondsSinceEpoch}',
      productId: product.id,
      productName: product.name,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      type: _type,
      quantity: quantity,
      unitPrice: product.unitPrice,
      createdAt: DateTime.now(),
    );

    final movements = [movement, ...ref.read(demoMovementsProvider)];
    ref.read(demoMovementsProvider.notifier).state = movements;
    DemoStockStorage.saveMovements(
      ref.read(sharedPreferencesProvider),
      movements,
    );
    _selectedProduct = updatedProduct;
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider).value ?? const <Product>[];
    final movements = ref.watch(movementsProvider);

    if (_selectedProduct == null && products.isNotEmpty) {
      _selectedProduct = products.first;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mouvement de stock',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SegmentedButton<MovementType>(
                  segments: const [
                    ButtonSegment(
                      value: MovementType.entry,
                      label: Text('Entree'),
                      icon: Icon(Icons.call_received),
                    ),
                    ButtonSegment(
                      value: MovementType.sale,
                      label: Text('Vente'),
                      icon: Icon(Icons.point_of_sale),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (value) =>
                      setState(() => _type = value.first),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Product>(
                  initialValue: products.contains(_selectedProduct)
                      ? _selectedProduct
                      : null,
                  decoration: const InputDecoration(labelText: 'Produit'),
                  items: products
                      .map(
                        (product) => DropdownMenuItem(
                          value: product,
                          child: Text('${product.name} (${product.quantity})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedProduct = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantity,
                  decoration: const InputDecoration(labelText: 'Quantite'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isSaving || products.isEmpty
                      ? null
                      : _saveMovement,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    _type == MovementType.entry
                        ? 'Entrer en stock'
                        : 'Valider la vente',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Historique', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        movements.when(
          data: (items) => items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucun mouvement.'),
                )
              : Column(
                  children: items
                      .map((movement) => _MovementTile(movement))
                      .toList(),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Erreur: $error'),
        ),
      ],
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile(this.movement);

  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final isSale = movement.type == MovementType.sale;
    return Card(
      child: ListTile(
        leading: Icon(isSale ? Icons.trending_down : Icons.trending_up),
        title: Text(movement.productName),
        subtitle: Text(
          '${movement.categoryName} - ${formatter.format(movement.createdAt)}',
        ),
        trailing: Text('${isSale ? '-' : '+'}${movement.quantity}'),
      ),
    );
  }
}
