import 'package:cash_control/bloc/blocs/courier_page_blocs/blocs/courier_document_bloc.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/blocs/packer_document_bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/packer_document_event.dart';
import 'package:cash_control/ui/courier/pages/consignment.dart';
import 'package:cash_control/ui/courier/pages/delivery_homescreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/blocs/chat_bloc.dart';
import 'package:cash_control/ui/courier/pages/chat.dart';
import 'package:cash_control/ui/main/widgets/profile.dart';
import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/courier/widgets/chat_service.dart';
class CourierDashboardScreen extends StatefulWidget {
  @override
  _CourierDashboardScreenState createState() => _CourierDashboardScreenState();
}

class _CourierDashboardScreenState extends State<CourierDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DeliveryHomeScreen(),
    InvoiceScreen(),
    ChatScreen(),
    const AccountView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
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
      create: (_) => CourierDocumentBloc()..add(FetchCourierDocumentsEvent()),
      child: InvoiceScreen(),
    ),
        BlocProvider(
          create: (_) => PackerDocumentBloc()..add(FetchPackerDocumentsEvent()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text(
            'Кабинет курьера',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
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
