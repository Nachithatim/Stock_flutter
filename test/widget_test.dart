import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_flutter/app.dart';
import 'package:stock_flutter/providers/app_providers.dart';

void main() {
  testWidgets('affiche le dashboard en mode demo sans Firebase', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseReadyProvider.overrideWithValue(false)],
        child: const StockSaasApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Etat de stock'), findsOneWidget);
    expect(find.text('Produits sous seuil'), findsOneWidget);
  });
}
