import 'package:flutter/material.dart';

import 'widgets/bottom_nav_bar.dart';

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
                _buildProductList(),
                _buildProductList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildProductList() {
    // Replace this with your actual Bloc logic to fetch products
    final dummyProducts = List.generate(
      10,
      (index) => {
        "name": "Product $index",
        "supplier": "Supplier $index",
        "image": "https://via.placeholder.com/60"
      },
    );

    final filteredProducts = dummyProducts.where((product) {
      return product['name']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Image.network(
              product['image']!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
            ),
            title: Text(product['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text('Поставщик: ${product['supplier']}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Add to cart logic
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Add to Cart'),
            ),
          ),
        );
      },
    );
  }
}
