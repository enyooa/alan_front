import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Two main colors from your screenshot:
const Color startColor = Color(0xFF0ABCD7); // #0ABCD7
const Color endColor   = Color(0xFF6CC6DA); // #6CC6DA

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Postupleniya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: startColor,
      ),
      home: const AdminPostupleniyaScreen(),
    );
  }
}

class AdminPostupleniyaScreen extends StatelessWidget {
  const AdminPostupleniyaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========== APP BAR with gradient ==========
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Админ поступления',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Handle back
          },
        ),
        actions: [
          // "фильтр" + icon
          TextButton.icon(
            onPressed: () {
              // Handle filter
            },
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.white,
            ),
            label: const Text(
              'фильтр',
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              // Handle close
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // =====================================
              // TABLE 1 HEADER (Таблица товаров)
              // =====================================
              Container(
                decoration: BoxDecoration(
                  // Use a single color or a mini-gradient if you want:
                  gradient: const LinearGradient(
                    colors: [startColor, endColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Таблица товаров',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // Handle delete
                          },
                          icon: const Icon(Icons.delete),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {
                            // Handle add
                          },
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================================
              // TABLE 1 COLUMNS
              // ================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  // Use our new color for the border:
                  border: Border.all(color: endColor, width: 1.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                margin: const EdgeInsets.only(top: 5),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.3), // "Товар"
                    1: FlexColumnWidth(1.3), // "Кол-во тары"
                    2: FlexColumnWidth(1.5), // "Ед. изм / Тара"
                    3: FlexColumnWidth(1.0), // "Брутто"
                    4: FlexColumnWidth(1.0), // "Цена"
                  },
                  border: TableBorder.symmetric(
                    inside: BorderSide(color: endColor, width: 1),
                  ),
                  children: [
                    // Header row
                    TableRow(
                      decoration: const BoxDecoration(color: startColor),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Товар',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Кол-во тары',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Ед. изм / Тара',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Брутто',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Цена',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ],
                    ),
                    // Data row example
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Товар -',
                              style: TextStyle(color: Colors.grey[800])),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('0', style: TextStyle(color: Colors.grey[800])),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Ед. -',
                              style: TextStyle(color: Colors.grey[800])),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('0', style: TextStyle(color: Colors.grey[800])),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('0', style: TextStyle(color: Colors.grey[800])),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================================
              // NETTO / SUMMA / ETC. LINES
              // ================================
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: endColor, width: 1.2),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Нетто:     Сумма:     Доп. расходы:     Себестоимость:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    // Example row 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Товар'),
                        Text('0'),
                        Text('Ед.'),
                        Text('Нетто:'),
                        Text('Сумма:'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Example row 2
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Товар'),
                        Text('0'),
                        Text('Ед.'),
                        Text(''),
                        Text(''),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================================
              // TABLE 2 HEADER (Доп. расходы)
              // ================================
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [startColor, endColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Доп. расходы',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // Handle delete
                          },
                          icon: const Icon(Icons.delete),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {
                            // Handle add
                          },
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================================
              // TABLE 2 COLUMNS
              // ================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: endColor, width: 1.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                margin: const EdgeInsets.only(top: 5),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2), // "Наименования"
                    1: FlexColumnWidth(1), // "Сумма"
                  },
                  border: TableBorder.symmetric(
                    inside: BorderSide(color: endColor, width: 1),
                  ),
                  children: [
                    // Header row
                    TableRow(
                      decoration: const BoxDecoration(color: startColor),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Наименования',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Сумма',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ],
                    ),
                    // Data row example
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Выберите ↓',
                              style: TextStyle(color: Colors.grey[800])),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Text('0', style: TextStyle(color: Colors.grey[800])),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================================
              // СОХРАНИТЬ BUTTON
              // ================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Use one color or a gradient ButtonStyle if you prefer
                    backgroundColor: startColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    // Handle save
                  },
                  child: const Text(
                    'Сохранить',
                    style: TextStyle(fontSize: 16),
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
