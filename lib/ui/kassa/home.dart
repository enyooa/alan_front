import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MarketingScreen(),
    );
  }
}

class MarketingScreen extends StatefulWidget {

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  int _selectedIndex = 0; 
 // Manage the selected tab index
  String searchQuery = ""; 
 // Store search query
  List<int> quantities = List<int>.filled(4, 0); 
 // Initialize with 4 products, all quantities set to 0
  List<Map<String, dynamic>> cartItems = [];

  final List<Widget> _screens = [
    CardScreen(), // Карточка
    CalculationScreen(), // Расчеты
    CartScreen(cartItems: const []), // Корзина (we will pass the cartItems later)
    FavoritesScreen(), // Избранное
    ProfileScreen(), // Профиль
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  final List<Map<String, String>> marketingCards = [
    {
      'title': 'приход',
      'image': 'assets/images/kassa/income.png',
    },
    {
      'title': 'расход',
      'image': 'assets/images/kassa/expenses.jpg',
    },
    {
      'title': 'отчеты по кассе',
      'image': 'assets/images/kassa/report.png',
    },
    {
      'title': 'отчеты по долгам',
      'image': 'assets/images/kassa/arears.png',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.blueAccent,
      child: Center(
        child: Text(
          'Касса',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: marketingCards.length,
          itemBuilder: (context, index) {
            return MarketingCard(
              title: marketingCards[index]['title']!,
              imagePath: marketingCards[index]['image']!,
            );
          },
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex, // Track the selected item index
      selectedItemColor: Colors.blueAccent, // Color for selected item
      unselectedItemColor: Colors.grey, // Color for unselected items
      onTap: _onItemTapped,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Карточка',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate),
          label: 'Расчеты',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.shopping_cart),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartItems.length}', // Show number of items in the cart
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
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

class MarketingCard extends StatelessWidget {
  final String title;
  final String imagePath;

  MarketingCard({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.arrow_forward_ios),
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
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Your build method implementation
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cartItems[index]['name']),
            subtitle: Text('Quantity: ${cartItems[index]['quantity']}'),
          );
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

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Профиль Screen'));
  }
}
