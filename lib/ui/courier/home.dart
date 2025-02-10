
       
import 'package:alan/bloc/blocs/courier_page_blocs/blocs/chat_bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/blocs/courier_order_bloc.dart';

import 'package:alan/bloc/blocs/courier_page_blocs/events/courier_order_event.dart';

import 'package:alan/constant.dart';
import 'package:alan/ui/courier/pages/main_page.dart';
import 'package:alan/ui/courier/widgets/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/ui/courier/pages/delivery_homescreen.dart';
import 'package:alan/ui/courier/pages/chat.dart';
import 'package:alan/ui/main/widgets/profile.dart';
class CourierDashboardScreen extends StatefulWidget {
  @override
  _CourierDashboardScreenState createState() => _CourierDashboardScreenState();
}

class _CourierDashboardScreenState extends State<CourierDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DeliveryHomeScreen(),
    HomeScreen(),
    ChatScreen(),
    const AccountView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        
        BlocProvider(
          create: (_) => ChatBloc(ChatService(baseUrl: baseUrl)),
        ),
         BlocProvider(
          create: (_) => CourierOrdersBloc(baseUrl: baseUrl)..add(FetchCourierOrdersEvent()),
        ),
        
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Кабинет курьера', style: TextStyle(color: Colors.white)),
          backgroundColor: primaryColor,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner),
              label: 'Документы',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Чат',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
