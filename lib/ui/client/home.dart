import 'package:cash_control/constant.dart';
import 'package:cash_control/bloc/blocs/product_bloc.dart';
import 'package:cash_control/bloc/events/product_event.dart';
import 'package:cash_control/bloc/states/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({Key? key}) : super(key: key);

  @override
  _ClientDashboardScreenState createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  // Dropdown filters
  String selectedStore = 'MAGNUM';
  String? selectedPrice;
  String? selectedBrand;
  String? selectedWeight;

  final List<String> priceOptions = ['Low to High', 'High to Low'];
  final List<String> brandOptions = ['Brand A', 'Brand B', 'Brand C'];
  final List<String> weightOptions = ['Up to 500g', '500g - 1kg', 'Above 1kg'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProductBloc>().add(FetchProductsEvent());
  }

  void _searchProduct(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search in Magnum',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _searchProduct,
              )
            : const Text('Product Listing'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  _searchProduct('');
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Все товары'),
            Tab(text: 'Сахар и заменители'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Dropdown Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<String>(
                  value: selectedStore,
                  items: ['MAGNUM'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => selectedStore = newValue!),
                ),
                DropdownButton<String>(
                  hint: const Text('Цена'),
                  value: selectedPrice,
                  items: priceOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => selectedPrice = newValue),
                ),
                DropdownButton<String>(
                  hint: const Text('Бренд'),
                  value: selectedBrand,
                  items: brandOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => selectedBrand = newValue),
                ),
                DropdownButton<String>(
                  hint: const Text('Вес/Количество'),
                  value: selectedWeight,
                  items: weightOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => selectedWeight = newValue),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // buildProductList(),
                // buildProductList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Catalog'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Orders'),
        ],
      ),
    );
  }

// Widget buildProductList() {
//   return BlocBuilder<ProductBloc, ProductState>(
//     builder: (context, state) {
//       if (state is ProductLoading) {
//         return const Center(child: CircularProgressIndicator());
//       } else if (state is ProductsLoaded) {
//         final filteredProducts = state.products.where((product) {
//           return product.nameOfProducts.toLowerCase().contains(searchQuery.toLowerCase());
//         }).toList();

//         return ListView.builder(
//           padding: const EdgeInsets.all(10),
//           itemCount: filteredProducts.length,
//           itemBuilder: (context, index) {
//             final product = filteredProducts[index];
            
//             // Use the `photoUrl` field instead of constructing the URL manually
//             final imageUrl = product.photoUrl ?? 'assets/images/placeholder.png';

//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               child: ListTile(
//                 leading: Image.network(
//                   imageUrl,
//                   width: 60,
//                   height: 60,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
//                 ),
//                 title: Text(product.nameOfProducts, style: bodyTextStyle),
//                 subtitle: Text('Поставщик: ${product.country}', style: captionStyle),
//                 trailing: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
//                   child: const Text('Add to Cart', style: buttonTextStyle),
//                 ),
//               ),
//             );
//           },
//         );
//       } else if (state is ProductError) {
//         return Center(child: Text('Error: ${state.message}', style: captionStyle));
//       }
//       return const Center(child: Text('No products available.'));
//     },
//   );
// }

 
 }
