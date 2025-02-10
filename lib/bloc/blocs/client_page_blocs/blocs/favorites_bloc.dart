import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/favorites_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/favorites_state.dart';
import 'package:alan/bloc/blocs/client_page_blocs/repositories/favorites_repository.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository repository;

  FavoritesBloc({required this.repository}) : super(FavoritesInitial()) {
    on<FetchFavoritesEvent>(_onFetchFavorites);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
  }

  Future<void> _onFetchFavorites(
    FetchFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getFavorites();
      emit(FavoritesLoaded(favorites, favorites.length));
    } catch (e) {
      emit(FavoritesError("Failed to fetch favorites: ${e.toString()}"));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    if (state is FavoritesLoaded) {
      final currentFavorites = (state as FavoritesLoaded).favorites;

      try {
        // Optimistic update
        final updatedFavorites = List<Map<String, dynamic>>.from(currentFavorites)
          ..add(event.product);
        emit(FavoritesLoaded(updatedFavorites, updatedFavorites.length));

        // Perform the API call
        await repository.addToFavorites(event.product);
      } catch (e) {
        emit(FavoritesError("Failed to add to favorites: ${e.toString()}"));
        emit(state); // Restore previous state
      }
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    if (state is FavoritesLoaded) {
      final currentFavorites = (state as FavoritesLoaded).favorites;

      try {
        // Optimistic update
        final updatedFavorites = currentFavorites
            .where((fav) => fav['product_subcard_id'] != event.productSubcardId)
            .toList();
        emit(FavoritesLoaded(updatedFavorites, updatedFavorites.length));

        // Perform the API call
        await repository.removeFromFavorites(event.productSubcardId);
      } catch (e) {
        emit(FavoritesError("Failed to remove from favorites: ${e.toString()}"));
        emit(state); // Restore previous state
      }
    }
  }
}
