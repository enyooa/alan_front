import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
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
                  'Поступление',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Search Bar Row
           
            // Column Headers
           
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Number of rows
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1), // Thinner border
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(''),
                          ),
                        ),
                        Container(
                          width: 1, // Thinner vertical line
                          color: Colors.black,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(''),
                          ),
                        ),
                        Container(
                          width: 1, // Thinner vertical line
                          color: Colors.black,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(''),
                          ),
                        ),
                        Container(
                          width: 1, // Thinner vertical line
                          color: Colors.black,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(''),
                          ),
                        ),
                        Container(
                          width: 1, // Thinner vertical line
                          color: Colors.black,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(''),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Buttons for "доп расходы" and "Оприходовать на склад"
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent[100],
                  side: BorderSide(color: Colors.black, width: 2),
                  padding: const EdgeInsets.all(16.0),
                ),
                onPressed: () {
                  // Action for "доп расходы"
                },
                child: Text(
                  'доп расходы',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent[100],
                side: BorderSide(color: Colors.black, width: 2),
                padding: const EdgeInsets.all(16.0),
              ),
              onPressed: () {
                // Action for "Оприходовать на склад"
              },
              child: Text(
                'Оприходовать на склад',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DataTableWidget(),
  ));
}
