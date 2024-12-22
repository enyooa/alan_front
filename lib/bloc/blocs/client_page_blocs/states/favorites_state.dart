abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Map<String, dynamic>> favorites;

  FavoritesLoaded(this.favorites);
}

class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError(this.message);
}
