import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Layout Example"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // First row (Supplier and Bell Icon)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.blue,
                      child: Text(
                        'Поставщик',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () {
                    
                  },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.blue,
                      child: Icon(Icons.notifications, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Second row (Access on the left and an empty space on the right)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            'Доступы',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Empty space
                    Expanded(
                      child: Container(
                        color: Colors.blue,
                        child: SizedBox(), // Empty container to match the layout
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              // Third row (References block at the bottom)
              Expanded(
                child: Container(
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'Справочник',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
