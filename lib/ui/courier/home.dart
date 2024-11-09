import 'package:cash_control/constant.dart';
import 'package:flutter/material.dart';


class CourierDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,

        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {},
        // ),
        title: Text('Кабинет курьера',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications,color: Colors.white,),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: 5, // Change this to your actual data count
        itemBuilder: (context, index) {
          return DeliveryItem();
        },
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

class DeliveryItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue),
              SizedBox(width: 8.0),
              Text('склад №1 Кажымуханова 55', style: TextStyle(fontSize: 16.0)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Column(
              children: [
                Icon(Icons.arrow_downward, color: Colors.blue),
                Row(
                  children: [
                    Icon(Icons.store, color: Colors.blue),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'магазин Магнум Есильский район ул.Сауран 5г',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
