import 'package:flutter/material.dart';

class ReferenceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Справочник")),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(title: Text('Приобретение бензина')),
          ListTile(title: Text('Продажа товаров')),
          ListTile(title: Text('Возврат средств')),
        ],
      ),
    );
  }
}
