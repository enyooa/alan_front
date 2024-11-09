import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/client/widgets/bottom_nav_bar.dart';
import 'package:cash_control/ui/main/profile.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(const MaterialApp(home: ClientDashboardScreen(),));
}


class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  _ClientDashboardScreenState createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 0;
  String searchQuery = "";

  List<int> quantities = List<int>.filled(4, 0);
  List<Map<String, dynamic>> cartItems = [];

  final List<Widget> _screens = [
    const CalculationScreen(),
    const CartScreen(cartItems: []),
        const CartScreen(cartItems: []),

    const AccountView(),
  ];

  void _searchProduct(String query) {
    setState(() {
      searchQuery = query;
    });
    print("Searching for: $query");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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

  void addToCart(int index) {
    String productName = products[index]['name']!;
    int quantity = quantities[index];

    setState(() {
      var existingProduct = cartItems.firstWhere(
          (item) => item['name'] == productName,
          orElse: () => {});
      if (existingProduct.isNotEmpty) {
        existingProduct['quantity'] = quantity;
      } else {
        cartItems.add({
          'name': productName,
          'quantity': quantity,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          if (_selectedIndex == 0)
            buildSupplierHeader(),
          Expanded(
            child: _selectedIndex == 0
                ? buildProductList() // Show ProductList content on the first screen
                : _screens[_selectedIndex - 1], // Adjusted index for other screens
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: isSearching
          ? TextField(
              controller: searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Поиск товара...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.grey),
              onChanged: (value) {
                _searchProduct(value);
              },
            )
          : const Text('Наименование товара'),
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
    );
  }

  Container buildSupplierHeader() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: primaryColor,
      child: const Center(
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

  Widget buildProductList() {
    List<Map<String, String>> filteredProducts = products.where((product) {
      return product['name']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          imageUrl: filteredProducts[index]['imageUrl']!,
          name: filteredProducts[index]['name']!,
          supplier: filteredProducts[index]['supplier']!,
          quantity: quantities[index],
          onQuantityChanged: (newQuantity) {
            setState(() {
              quantities[index] = newQuantity;
              if (newQuantity > 0) {
                addToCart(index);
              }
            });
          },
        );
      },
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      items: const [
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

  const ProductCard({super.key, 
    required this.imageUrl,
    required this.name,
    required this.supplier,
    required this.quantity, // Add quantity to the constructor
    required this.onQuantityChanged, // Add callback for quantity change
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 1),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
      
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 20,),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset(
                  imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      supplier,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {
                              // Add to favorites functionality here
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined),
                            onPressed: () {
                              // Add to cart functionality here
                            },
                          ),
                          
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (quantity > 0) {
                                onQuantityChanged(quantity - 1); // Decrease quantity
                              }
                            },
                          ),
                          Text(
                            '$quantity', // Display current quantity
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                onQuantityChanged(quantity + 1); // Increase quantity
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Example screens for each tab


class CalculationScreen extends StatelessWidget {
  const CalculationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Расчеты Screen'));
  }
}

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'корзина',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Магнум Сагынак 33',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Cart items
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Checkbox(
                      value: cartItems[index]['selected'],
                      onChanged: (value) {
                        // Handle checkbox change
                      },
                    ),
                    title: Row(
                      children: [
                        Image.network(
                          cartItems[index]['image'],
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItems[index]['name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'цена ${cartItems[index]['price']} ед. изм ${cartItems[index]['unit']}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(color: Colors.grey, thickness: 0.5, height: 20),

            // Delivery date section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Доставка до (календарь)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: () {
                    // Show date picker
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Checkout button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle checkout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'Оформить заказ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Set the selected index
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'расчеты',
          ),
        ],
        onTap: (index) {
          // Handle bottom navigation item selection
        },
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Избранное Screen'));
  }
}
