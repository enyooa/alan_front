import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OrderPage(),
    );
  }
}

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
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
      padding: EdgeInsets.all(10),
      color: Colors.blueAccent,
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18),
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
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: 
          Column(children: [
            Image.asset(imagePath, width: 50, height: 50),
            SizedBox(height: 20,),
            Icon(Icons.comment),
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
                IconButton(icon: Icon(Icons.remove), onPressed: () {}),
                Text('1'),
                IconButton(icon: Icon(Icons.add), onPressed: () {}),
              ],
            ),
            Text('Итого: $price ₸', style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Заявка',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 5),
          Text('Адрес доставки: г. Астана ул. Алматы 3, ТЦ Сауран'),
          Text('Телефон: 8777 123 45 67'),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Center(
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
      items: [
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
