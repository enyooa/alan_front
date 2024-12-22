import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/favorites_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/favorites_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesLoaded) {
            final favorites = state.favorites;

            if (favorites.isEmpty) {
              return const Center(
                child: Text(
                  'Нет избранных товаров.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                final product = favorite['product_subcard']['product_card'];
                final photoUrl = product['photo_product'] ?? '';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported, size: 40),
                    title: Text(
                      product['name_of_products'] ?? 'Товар',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      product['description'] ?? 'Описание отсутствует',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context.read<FavoritesBloc>().add(
                              RemoveFromFavoritesEvent(
                                productSubcardId: favorite['product_subcard_id'].toString(),
                              ),
                            );
                      },
                    ),
                  ),
                );
              },
            );
          } else if (state is FavoritesError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          } else {
            return const Center(child: Text('Не удалось загрузить данные.'));
          }
        },
      ),
    );
  }
}
