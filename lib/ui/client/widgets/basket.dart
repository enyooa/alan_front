import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: OrderPage(),
    );
  }
}

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Наименование товара',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          _buildSupplierSection('Выбор поставщика'),
          _buildProductList(),
          _buildOrderSection(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSupplierSection(String title) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.blueAccent,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildProductList() {
    return Expanded(
      child: ListView(
        children: [
          _buildProductItem(
              'Поставщик: TOO Шанырак', 'КГ', 'Сайрам Туркестан', 100, 'images/banana.png'),
          _buildProductItem(
              'Поставщик: TOO Жертумыс', 'КОРОБКА', 'Сайрам Туркестан', 100, 'images/banana.png'),
        ],
      ),
    );
  }

  Widget _buildProductItem(
      String supplier, String unit, String product, int price, String imagePath) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: 
          Column(children: [
            Image.asset(imagePath, width: 50, height: 50),
            const SizedBox(height: 20,),
            const Icon(Icons.comment),
          ],
          ),
        title: Text('$unit - $product'),
        
        subtitle: Text(supplier),
        
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.remove), onPressed: () {}),
                const Text('1'),
                IconButton(icon: const Icon(Icons.add), onPressed: () {}),
              ],
            ),
            Text('Итого: $price ₸', style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Заявка',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          const Text('Адрес доставки: г. Астана ул. Алматы 3, ТЦ Сауран'),
          const Text('Телефон: 8777 123 45 67'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Center(
              child: Text(
                'ОТПРАВИТЬ ЗАЯВКУ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'Товары',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Поставщики',
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
          icon: Icon(Icons.account_circle),
          label: 'Профиль',
        ),
      ],
    );
  }
}
