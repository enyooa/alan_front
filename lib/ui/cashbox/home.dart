import 'package:cash_control/constant.dart';
import 'package:flutter/material.dart';

class CashboxDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReferenceScreen(),
    );
  }
}

class ReferenceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Справочник',style: TextStyle(color: Colors.white),),
        
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Expanded(
            child: CategorySection(
              title: 'Статьи расходов',
              items: ['Приобретение бензина', 'Приобретение канц товаров', 'Приобретение мыломоющих средств'],
            ),
          ),
          SizedBox(height: 24.0),
          Expanded(
            child: CategorySection(
              title: 'Статьи движение денег',
              items: ['Продажа товаров', 'Возврат средств', 'Поступление'],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Приходный ордер'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Расходный ордер'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Расчеты с поставщиком'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Отчет по кассе'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Справочник'),
        ],
        currentIndex: 4, // Highlight 'Справочник' as active
        onTap: (index) {
          // Handle navigation tap
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final String title;
  final List<String> items;

  const CategorySection({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...items.map((item) => CategoryItem(item: item)).toList(),
      ],
    );
  }
}
class CategoryItem extends StatelessWidget {
  final String item;

  const CategoryItem({Key? key, required this.item}) : super(key: key);

  void editCategory(BuildContext context, String category) {
    // Handle edit category logic here
  }

  void deleteCategory(BuildContext context, String category) {
    // Handle delete category logic here
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item, style: TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => editCategory(context, item),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteCategory(context, item),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
