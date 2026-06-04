import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/app_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final range = ref.watch(dashboardRangeProvider);
    final currency = NumberFormat.currency(locale: 'fr_MA', symbol: 'DH');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: DateTimeRange(
                    start: range.start,
                    end: range.end,
                  ),
                );
                if (picked != null) {
                  ref.read(dashboardRangeProvider.notifier).state =
                      DateTimeRangeValue(start: picked.start, end: picked.end);
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                '${DateFormat('dd/MM').format(range.start)} - ${DateFormat('dd/MM').format(range.end)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            mainAxisExtent: 118,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          children: [
            _MetricCard(
              title: 'Etat de stock',
              value: currency.format(stats.stockValue),
              icon: Icons.inventory_2,
            ),
            _MetricCard(
              title: 'Ventes',
              value: currency.format(stats.salesAmount),
              icon: Icons.point_of_sale,
            ),
            _MetricCard(
              title: 'Alertes seuil',
              value: '${stats.lowStockProducts.length}',
              icon: Icons.notification_important,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Produits les plus vendus',
          children: stats.topProducts.isEmpty
              ? const [Text('Aucune vente dans cette plage.')]
              : stats.topProducts
                    .map(
                      (product) => ListTile(
                        leading: const Icon(Icons.emoji_events_outlined),
                        title: Text(product.productName),
                        trailing: Text('${product.quantity} vendus'),
                      ),
                    )
                    .toList(),
        ),
        _SectionCard(
          title: 'Ventes par categorie',
          children: stats.salesByCategory.isEmpty
              ? const [Text('Aucune categorie vendue.')]
              : stats.salesByCategory
                    .map(
                      (category) => ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: Text(category.categoryName),
                        trailing: Text(currency.format(category.amount)),
                      ),
                    )
                    .toList(),
        ),
        _SectionCard(
          title: 'Produits sous seuil',
          children: stats.lowStockProducts.isEmpty
              ? const [Text('Aucune notification de reassort.')]
              : stats.lowStockProducts
                    .map(
                      (product) => ListTile(
                        leading: const Icon(Icons.warning_amber),
                        title: Text(product.name),
                        subtitle: Text(product.categoryName),
                        trailing: Text(
                          '${product.quantity}/${product.threshold}',
                        ),
                      ),
                    )
                    .toList(),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
