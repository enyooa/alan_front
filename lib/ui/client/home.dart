import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool isSearching = false; // Toggle between title and search field
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 0; // Manage the selected tab index
  String searchQuery = ""; // Store search query

  // Store quantity for each product
  List<int> quantities = List<int>.filled(4, 0); // Initialize with 4 products, all quantities set to 0

  final List<Widget> _screens = [
    CardScreen(), // Карточка
    CalculationScreen(), // Расчеты
    CartScreen(), // Корзина
    FavoritesScreen(), // Избранное
    ProfileScreen(), // Профиль
  ];

  // Function to handle searching products
  void _searchProduct(String query) {
    setState(() {
      searchQuery = query;
    });
    print("Searching for: $query");
  }

  // Method to handle screen switch
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // List of products
  final List<Map<String, String>> products = [
    {
      'imageUrl': 'assets/images/products/potato.png',
      'name': 'Картофель',
      'supplier': 'Поставщик: TOO Ахат\nЕд. Из. Мешок',
    },
    {
      'imageUrl': 'assets/images/products/tomato.png',
      'name': 'Помидоры',
      'supplier': 'Поставщик: TOO Ахат\nЕд. Из. КОРОБКА',
    },
    {
      'imageUrl': 'assets/images/products/cucumber.png',
      'name': 'Огурцы',
      'supplier': 'Поставщик: ИП Сасик\nЕд. Из. КГ',
    },
    {
      'imageUrl': 'assets/images/products/banana.png',
      'name': 'Бананы',
      'supplier': 'Поставщик: ИП Сасик\nЕд. Из. КОРОБКА',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          if (_selectedIndex == 0) buildSupplierHeader(), // Only show on Product List screen
          Expanded(
            child: _selectedIndex == 0 // Check if current tab is "Product List"
                ? buildProductList()
                : _screens[_selectedIndex], // Show other screens based on index
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  // Build AppBar with search functionality
  AppBar buildAppBar() {
    return AppBar(
      title: isSearching
          ? TextField(
              controller: searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Поиск товара...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                _searchProduct(value); // Call your search logic here
              },
            )
          : Text('Наименование товара'),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (isSearching) {
                searchController.clear();
                _searchProduct(''); // Clear search results
              }
              isSearching = !isSearching;
            });
          },
        ),
      ],
    );
  }

  // Build supplier header section
  Container buildSupplierHeader() {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.blueAccent,
      child: Center(
        child: Text(
          'Выбор поставщика',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // Build the product list with the ability to filter by search query
  Widget buildProductList() {
    List<Map<String, String>> filteredProducts = products.where((product) {
      return product['name']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          imageUrl: filteredProducts[index]['imageUrl']!,
          name: filteredProducts[index]['name']!,
          supplier: filteredProducts[index]['supplier']!,
          quantity: quantities[index], // Pass current quantity
          onQuantityChanged: (newQuantity) {
            setState(() {
              quantities[index] = newQuantity; // Update quantity for the specific product
            });
          },
        );
      },
    );
  }

  // Bottom navigation bar
  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex, // Track the selected item index
      selectedItemColor: Colors.blueAccent, // Color for selected item
      unselectedItemColor: Colors.grey, // Color for unselected items
      onTap: _onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Карточка',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate),
          label: 'Расчеты',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Корзина',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Избранное',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ],
    );
  }
}

// ProductCard with external quantity management
class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String supplier;
  final int quantity; // Quantity from the parent
  final ValueChanged<int> onQuantityChanged; // Callback to update quantity

  ProductCard({
    required this.imageUrl,
    required this.name,
    required this.supplier,
    required this.quantity, // Add quantity to the constructor
    required this.onQuantityChanged, // Add callback for quantity change
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    supplier,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite_border),
                        onPressed: () {
                          // Add to favorites functionality here
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined),
                        onPressed: () {
                          // Add to cart functionality here
                        },
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 0) {
                            onQuantityChanged(quantity - 1); // Decrease quantity
                          }
                        },
                      ),
                      Text(
                        '$quantity', // Display current quantity
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          onQuantityChanged(quantity + 1); // Increase quantity
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example screens for each tab
class CardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Карточка Screen'));
  }
}

class CalculationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Расчеты Screen'));
  }
}

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Корзина Screen'));
  }
}

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Избранное Screen'));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Профиль Screen'));
  }
}
