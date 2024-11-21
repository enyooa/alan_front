import 'package:flutter/material.dart';


class DocumentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Документ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {

            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              style: const TextStyle(fontSize: 16.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (checked)
            const Icon(Icons.check, color: Colors.blue, size: 28.0),
        ],
      ),
    );
  }
}
