import 'package:equatable/equatable.dart';

abstract class FavoritesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Map<String, dynamic>> favorites;
  final int totalFavorites; // Keep track of the total favorites count

  FavoritesLoaded(this.favorites, this.totalFavorites);

  @override
  List<Object?> get props => [favorites, totalFavorites];
}

class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}
