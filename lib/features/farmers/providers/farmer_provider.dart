import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/farmer_repository.dart';
import '../models/farmer_model.dart';

final farmerRepositoryProvider = Provider((ref) => FarmerRepository());

// Holds the currently selected farmer
final selectedFarmerProvider = StateProvider<FarmerModel?>((ref) => null);

// Search state
class FarmerSearchNotifier extends StateNotifier<AsyncValue<FarmerModel?>> {
  FarmerSearchNotifier(this._repo) : super(const AsyncData(null));

  final FarmerRepository _repo;

  Future<void> search(String query) async {
    state = const AsyncLoading();
    try {
      final farmer = await _repo.search(query);
      state = AsyncData(farmer);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  void clear() => state = const AsyncData(null);
}

final farmerSearchProvider =
    StateNotifierProvider<FarmerSearchNotifier, AsyncValue<FarmerModel?>>(
      (ref) => FarmerSearchNotifier(ref.read(farmerRepositoryProvider)),
    );
