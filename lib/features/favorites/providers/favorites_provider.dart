import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteItem {
  const FavoriteItem({required this.id, required this.title, this.subtitle});

  final String id;
  final String title;
  final String? subtitle;
}

class FavoritesState {
  const FavoritesState({this.items = const []});

  final List<FavoriteItem> items;
  int get count => items.length;
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier() : super(const FavoritesState());

  void addItem(FavoriteItem item) {
    state = FavoritesState(items: [...state.items, item]);
  }

  void removeItem(String id) {
    state = FavoritesState(items: state.items.where((item) => item.id != id).toList());
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>(
  (ref) => FavoritesNotifier(),
);

final followingCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).count;
});
