import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import '../../../bloc/blocs/admin_page_blocs/blocs/product_sale_bloc.dart';
import '../../../bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import '../../../bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import '../../../bloc/blocs/admin_page_blocs/states/product_sale_state.dart';
import '../../../bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';

class ProductList extends StatelessWidget {
  final String searchQuery;

  const ProductList({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, salesState) {
        if (salesState is SalesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (salesState is SalesLoaded) {
          final sales = salesState.salesList;

          return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
            builder: (context, subcardState) {
              if (subcardState is ProductSubCardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (subcardState is ProductSubCardsLoaded) {
                final subcards = subcardState.productSubCards;

                return BlocBuilder<ProductCardBloc, ProductCardState>(
                  builder: (context, cardState) {
                    if (cardState is ProductCardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (cardState is ProductCardsLoaded) {
                      final productCards = cardState.productCards;

                      // Combine sales, subcards, and product cards
                      final combinedData = sales.map((sale) {
                        final subcard = subcards.firstWhere(
                          (sub) => sub['id'] == sale['product_subcard_id'],
                          orElse: () => Map<String,dynamic>(),
                        );

                        final productCard = subcard != null
    ? productCards.firstWhere(
        (card) => card['id'] == subcard['product_card_id'],

        orElse: () => <String, dynamic>{}, // Default to empty map
      )
    : null;

// Debugging print to check if productCard is loaded correctly
print('Subcard: $subcard');
print('ProductCard: $productCard');


                        return {
                          'sale': sale,
                          'subcard_name': subcard?['name'] ?? 'Unnamed Subcard',
                          'product_card': productCard,
                          'photo_url': productCard?['photo_url'] ?? '',
                        };
                      }).toList();

                      // Filter combined data based on search query
                      final filteredData = combinedData.where((data) {
                        final subcardName =
                            data['subcard_name'].toString().toLowerCase();
                        return subcardName.contains(searchQuery.toLowerCase());
                      }).toList();

                      return ListView.builder(
  itemCount: filteredData.length,
  itemBuilder: (context, index) {
    final item = filteredData[index];
    final productCard = item['product_card'] ?? {}; // Default to empty map if null
    final photoUrl = productCard['photo_url'] ?? ''; // Handle null photo_url
    final description = productCard['description'] ?? 'No description available'; // Handle null description

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Product Image
          photoUrl.isNotEmpty
              ? Image.network(
                  photoUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 80),
                )
              : const Icon(Icons.image_not_supported, size: 80),
          const SizedBox(width: 8),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['subcard_name'] ?? 'Unnamed Subcard',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount: ${item['sale']['amount']}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Unit: ${item['sale']['unit_measurement']}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Price: ${item['sale']['price']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
);
} else {
                      return const Center(child: Text('Failed to load product cards.'));
                    }
                  },
                );
              } else {
                return const Center(child: Text('Failed to load subcards.'));
              }
            },
          );
        } else {
          return const Center(child: Text('Failed to load sales.'));
        }
      },
    );
  }
}
