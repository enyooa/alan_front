import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchFavoritesEvent extends FavoritesEvent {}

class AddToFavoritesEvent extends FavoritesEvent {
  final Map<String, dynamic> product;

  AddToFavoritesEvent({required this.product});

  @override
  List<Object?> get props => [product];
}

class RemoveFromFavoritesEvent extends FavoritesEvent {
  final String productSubcardId;

  RemoveFromFavoritesEvent({required this.productSubcardId});

  @override
  List<Object?> get props => [productSubcardId];
}
