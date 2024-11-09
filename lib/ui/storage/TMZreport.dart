import 'package:flutter/material.dart';

class TMZReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Оприходование ТМЗ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Header row
            Container(
              color: Colors.blue[700],
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Оприходование ТМЗ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Create Document Button Row
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blueAccent[100],
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'создать документ',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  Expanded(child: Container()), // Empty space for now
                ],
              ),
            ),
            // Search Bar with headers
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'поиск по контрагенту',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'дата',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'сумма',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Documents List
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Number of rows
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'список документов',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Expanded(child: Container()), // Empty space for now
                        Expanded(child: Container()), // Empty space for now
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

