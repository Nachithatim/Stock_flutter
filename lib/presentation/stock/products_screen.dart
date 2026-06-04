import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      await ref
          .read(stockRepositoryProvider)
          .createProduct(
            clientId: ref.read(clientIdProvider),
            name: _name.text,
            categoryName: _category.text,
            threshold: int.parse(_threshold.text),
            unitPrice: double.parse(_price.text.replaceAll(',', '.')),
          );
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
