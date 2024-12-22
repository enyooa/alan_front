abstract class FavoritesEvent {}

class FetchFavoritesEvent extends FavoritesEvent {}

class AddToFavoritesEvent extends FavoritesEvent {
  final Map<String, dynamic> product;
  AddToFavoritesEvent({required this.product});
}

class RemoveFromFavoritesEvent extends FavoritesEvent {
  final String productSubcardId;
  RemoveFromFavoritesEvent({required this.productSubcardId});
}
