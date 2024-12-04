import 'package:cash_control/bloc/blocs/client_page_blocs/events/favorite_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/favorite_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesState({}));

  @override
  Stream<FavoritesState> mapEventToState(FavoritesEvent event) async* {
    if (event is ToggleFavoriteEvent) {
      final updatedFavorites = Set<String>.from(state.favoriteIds);
      if (updatedFavorites.contains(event.productId)) {
        updatedFavorites.remove(event.productId);
      } else {
        updatedFavorites.add(event.productId);
      }
      yield FavoritesState(updatedFavorites);
    }
  }

  bool isFavorite(String productId) => state.favoriteIds.contains(productId);
}