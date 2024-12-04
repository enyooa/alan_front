import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final String productId;
  ToggleFavoriteEvent(this.productId);
}
