import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DocumentScreen(),
    );
  }
}

class DocumentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text('Документ'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DocumentItem(
              text: 'магазин Магнум Есильский район ул.Сауран 5г',
              checked: true,
            ),
            DocumentItem(
              text: 'магазин Магнум Есильский район ул.Сауран 5г',
              checked: true,
            ),
            DocumentItem(
              text: 'магазин Магнум Есильский район ул.Сауран 5г',
              checked: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Документ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Чат',
          ),
        ],
        onTap: (index) {
          // Handle bottom navigation tap
        },
      ),
    );
  }
}

class DocumentItem extends StatelessWidget {
  final String text;
  final bool checked;

  DocumentItem({required this.text, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (checked)
            Icon(Icons.check, color: Colors.blue, size: 28.0),
        ],
      ),
    );
  }
}
