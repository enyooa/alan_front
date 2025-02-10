import 'package:alan/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/blocs/courier_order_bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/events/courier_order_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/courier_order_state.dart';

import 'package:alan/constant.dart';
import 'package:alan/ui/Courier/widgets/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              CourierOrdersBloc(baseUrl: baseUrl)..add(FetchCourierOrdersEvent()),
        ),
        BlocProvider(
        create: (context) => AuthBloc()..add(FetchCourierUsersEvent())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Заявки',
            style: headingStyle, // Using headingStyle from constant.dart
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(horizontalPadding),
          child: BlocBuilder<CourierOrdersBloc, CourierOrdersState>(
            builder: (context, state) {
              if (state is CourierOrdersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CourierOrdersLoaded) {
                final orders = state.orders;

                if (orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет доступных заявок',
                      style: bodyTextStyle, // Using bodyTextStyle
                    ),
                  );
                }

                return ListView.builder(
  itemCount: orders.length,
  itemBuilder: (context, index) {
    final order = orders[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Адрес: ${order['address'] ?? 'Не указан'}',
              style: subheadingStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Статус: ${_translateStatus(order['status'])}',
              style: bodyTextStyle.copyWith(
                color: _getStatusColor(order['status']),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (order['order_products'].isNotEmpty)
              Text(
                'Количество продуктов: ${order['order_products'].length}',
                style: bodyTextStyle,
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: elevatedButtonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(orderId: order['id']),
                  ),
                );
              },
              child: const Text(
                'Детали',
                style: buttonTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  },
);
} else if (state is CourierOrdersError) {
                return Center(
                  child: Text(
                    'Ошибка: ${state.message}',
                    style: bodyTextStyle.copyWith(color: errorColor),
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    'Ошибка загрузки заявок.',
                    style: bodyTextStyle,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  /// Translate status to Russian dynamically
  String _translateStatus(String status) {
    const statusTranslations = {
      'pending': 'В ожидании',
      'processing': 'В обработке',
      'delivered': 'Доставлено',
      'shipped': 'Передано курьеру',
      'canceled': 'Отменено',
    };

    return statusTranslations[status] ?? 'Неизвестный статус';
  }

  /// Get color based on order status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.cyan;
      case 'canceled':
        return Colors.red;
      default:
        return textColor; // Default color from constants
    }
  }
}
