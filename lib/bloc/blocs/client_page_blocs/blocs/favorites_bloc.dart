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
      FetchFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getFavorites();
      emit(FavoritesLoaded(favorites, favorites.length));
    } catch (e) {
      emit(FavoritesError("Failed to fetch favorites: ${e.toString()}"));
    }
  }

  Future<void> _onAddToFavorites(
      AddToFavoritesEvent event, Emitter<FavoritesState> emit) async {
    try {
      await repository.addToFavorites(event.product);
      add(FetchFavoritesEvent()); // Dynamically refresh favorites
    } catch (e) {
      emit(FavoritesError("Failed to add to favorites: ${e.toString()}"));
      emit(state); // Re-emit current state to avoid leaving an error state
    }
  }

  Future<void> _onRemoveFromFavorites(
      RemoveFromFavoritesEvent event, Emitter<FavoritesState> emit) async {
    try {
      await repository.removeFromFavorites(event.productSubcardId);
      add(FetchFavoritesEvent()); // Dynamically refresh favorites
    } catch (e) {
      emit(FavoritesError("Failed to remove from favorites: ${e.toString()}"));
      emit(state); // Re-emit current state to avoid leaving an error state
    }
  }
}
