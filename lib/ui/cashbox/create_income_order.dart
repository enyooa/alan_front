import 'package:cash_control/constant.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CreateOrderScreen(),
    );
  }
}

class CreateOrderScreen extends StatefulWidget {
  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  String? selectedAccount;
  String? selectedPartner;
  String? selectedMovement;
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Справочник',style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back navigation
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        labelText: 'счет кассы . (выбор)',
                      ),
                      items: ['Option 1', 'Option 2', 'Option 3']
                          .map((option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAccount = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        labelText: 'Контрагент (выбор)',
                      ),
                      items: ['Partner 1', 'Partner 2', 'Partner 3']
                          .map((option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPartner = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        labelText: 'Статья движения',
                      ),
                      items: ['Movement 1', 'Movement 2', 'Movement 3']
                          .map((option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMovement = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        labelText: 'Сумма (водиться вручную)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 150,
                      width: double.infinity,
                      color: primaryColor,
                      child: Center(
                        child: Text(
                          'здесь фото чека',
                          style: TextStyle(color: Colors.white,),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle save action
              },
              child: Text('Сохранить',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Приходный ордер'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Расходный ордер'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Расчеты с поставщиком'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Отчет по кассе'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Справочник'),
        ],
        currentIndex: 0, // Highlight 'Приходный ордер' as active
        onTap: (index) {
          // Handle navigation tap
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
