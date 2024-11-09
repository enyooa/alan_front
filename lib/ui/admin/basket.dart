import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Listing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListingPage(),
    );
  }
}

class ProductListingPage extends StatefulWidget {
  @override
  _ProductListingPageState createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dropdown values
  String selectedStore = 'MAGNUM';
  String? selectedPrice;
  String? selectedBrand;
  String? selectedWeight;

  final List<String> priceOptions = ['Low to High', 'High to Low'];
  final List<String> brandOptions = ['Brand A', 'Brand B', 'Brand C'];
  final List<String> weightOptions = ['Up to 500g', '500g - 1kg', 'Above 1kg'];

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Fit Parad Sweetener №10 100 pcs',
      'type': 'Sugar and Sweeteners',
      'price': '1285 ₸',
      'rating': 4.5,
      'reviews': 54,
      'imageUrl': 'https://example.com/image1.jpg',
    },
    {
      'name': 'Fit Parad Sweetener №14 100 pcs',
      'type': 'Sugar and Sweeteners',
      'price': '1369 ₸',
      'rating': 4.5,
      'reviews': 29,
      'imageUrl': 'https://example.com/image2.jpg',
    },
    {
      'name': 'Mir Krup White Sugar 800 g',
      'type': 'Sugar and Sweeteners',
      'price': '679 ₸',
      'rating': 4.5,
      'reviews': 6,
      'imageUrl': 'https://example.com/image3.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search in Magnum',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
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
                  items: ['MAGNUM'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedStore = newValue!;
                    });
                  },
                ),
                DropdownButton<String>(
                  hint: Text('Цена'),
                  value: selectedPrice,
                  items: priceOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedPrice = newValue;
                    });
                  },
                ),
                DropdownButton<String>(
                  hint: Text('Бренд'),
                  value: selectedBrand,
                  items: brandOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedBrand = newValue;
                    });
                  },
                ),
                DropdownButton<String>(
                  hint: Text('Вес/Количество'),
                  value: selectedWeight,
                  items: weightOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedWeight = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildProductList(),
                buildProductList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Catalog'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Orders'),
        ],
      ),
    );
  }

  Widget buildProductList() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Image.network(
              product['imageUrl'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(product['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['type']),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    SizedBox(width: 4),
                    Text('${product['rating']} (${product['reviews']} reviews)'),
                  ],
                ),
                Text(product['price'], style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {},
              child: Text('Add to Cart'),
            ),
          ),
        );
      },
    );
  }
}
