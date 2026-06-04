import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/network/dio_client.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/stock_repository.dart';
import '../data/services/firestore_stock_service.dart';
import '../domain/models/category.dart';
import '../domain/models/dashboard_stats.dart';
import '../domain/models/product.dart';
import '../domain/models/stock_movement.dart';

final firebaseReadyProvider = Provider<bool>((ref) => true);

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository(FirestoreStockService(FirebaseFirestore.instance));
});

final authStateProvider = StreamProvider<User?>((ref) {
  final firebaseReady = ref.watch(firebaseReadyProvider);
  if (!firebaseReady) {
    return const Stream<User?>.empty();
  }
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final clientIdProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).value;
  return user?.uid ?? 'demo-client';
});

final productsProvider = StreamProvider<List<Product>>((ref) {
  final firebaseReady = ref.watch(firebaseReadyProvider);
  if (!firebaseReady) {
    return Stream.value(const <Product>[]);
  }
  return ref
      .watch(stockRepositoryProvider)
      .watchProducts(ref.watch(clientIdProvider));
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final firebaseReady = ref.watch(firebaseReadyProvider);
  if (!firebaseReady) {
    return Stream.value(const <Category>[]);
  }
  return ref
      .watch(stockRepositoryProvider)
      .watchCategories(ref.watch(clientIdProvider));
});

final movementsProvider = StreamProvider<List<StockMovement>>((ref) {
  final firebaseReady = ref.watch(firebaseReadyProvider);
  if (!firebaseReady) {
    return Stream.value(const <StockMovement>[]);
  }
  return ref
      .watch(stockRepositoryProvider)
      .watchMovements(ref.watch(clientIdProvider));
});

final dashboardRangeProvider = StateProvider<DateTimeRangeValue>((ref) {
  final now = DateTime.now();
  return DateTimeRangeValue(
    start: now.subtract(const Duration(days: 30)),
    end: now,
  );
});

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final products = ref.watch(productsProvider).value ?? const <Product>[];
  final movements =
      ref.watch(movementsProvider).value ?? const <StockMovement>[];
  final range = ref.watch(dashboardRangeProvider);
  return DashboardStats.fromData(
    products: products,
    movements: movements,
    start: range.start,
    end: range.end,
  );
});

class DateTimeRangeValue {
  const DateTimeRangeValue({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
