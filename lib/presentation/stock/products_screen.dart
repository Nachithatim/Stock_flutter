import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/demo_stock_storage.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../../providers/app_providers.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _threshold = TextEditingController(text: '5');
  final _price = TextEditingController(text: '0');
  var _isSaving = false;

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _threshold.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final firebaseReady = ref.read(firebaseReadyProvider);
      if (firebaseReady) {
        await ref
            .read(stockRepositoryProvider)
            .createProduct(
              clientId: ref.read(clientIdProvider),
              name: _name.text,
              categoryName: _category.text,
              threshold: int.parse(_threshold.text),
              unitPrice: double.parse(_price.text.replaceAll(',', '.')),
            );
      } else {
        _saveDemoProduct();
      }
      _name.clear();
      _category.clear();
      _threshold.text = '5';
      _price.text = '0';
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _saveDemoProduct() {
    final categories = ref.read(demoCategoriesProvider);
    final categoryName = _category.text.trim();
    final normalizedCategory = categoryName.toLowerCase();
    var category = categories
        .where((item) => item.name.trim().toLowerCase() == normalizedCategory)
        .firstOrNull;

    if (category == null) {
      category = Category(
        id: 'cat-${DateTime.now().microsecondsSinceEpoch}',
        name: categoryName,
        createdAt: DateTime.now(),
      );
      ref.read(demoCategoriesProvider.notifier).state = [
        ...categories,
        category,
      ];
      DemoStockStorage.saveCategories(
        ref.read(sharedPreferencesProvider),
        ref.read(demoCategoriesProvider),
      );
    }

    final product = Product(
      id: 'prod-${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      categoryId: category.id,
      categoryName: category.name,
      quantity: 0,
      threshold: int.parse(_threshold.text),
      unitPrice: double.parse(_price.text.replaceAll(',', '.')),
      createdAt: DateTime.now(),
    );

    final products = [...ref.read(demoProductsProvider), product];
    ref.read(demoProductsProvider.notifier).state = products;
    DemoStockStorage.saveProducts(
      ref.read(sharedPreferencesProvider),
      products,
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajouter un produit',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nom produit'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _category,
                    decoration: InputDecoration(
                      labelText: 'Categorie',
                      helperText: categories.isEmpty
                          ? 'Si elle n existe pas, elle sera ajoutee.'
                          : 'Categories: ${categories.map((c) => c.name).join(', ')}',
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _threshold,
                          decoration: const InputDecoration(
                            labelText: 'Seuil approvisionnement',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _positiveInt,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _price,
                          decoration: const InputDecoration(
                            labelText: 'Prix unitaire',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _positiveDouble,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveProduct,
                    icon: const Icon(Icons.add_box_outlined),
                    label: Text(_isSaving ? 'Enregistrement...' : 'Ajouter'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Catalogue', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        products.when(
          data: (items) => items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucun produit pour ce client.'),
                )
              : Column(children: items.map(_ProductTile.new).toList()),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Erreur: $error'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Champ obligatoire' : null;
  }

  String? _positiveInt(String? value) {
    final parsed = int.tryParse(value ?? '');
    return parsed == null || parsed < 0 ? 'Nombre invalide' : null;
  }

  String? _positiveDouble(String? value) {
    final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
    return parsed == null || parsed < 0 ? 'Montant invalide' : null;
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          product.isBelowThreshold
              ? Icons.notification_important
              : Icons.inventory,
          color: product.isBelowThreshold ? Colors.red : null,
        ),
        title: Text(product.name),
        subtitle: Text('${product.categoryName} - seuil ${product.threshold}'),
        trailing: Text('${product.quantity} en stock'),
      ),
    );
  }
}
