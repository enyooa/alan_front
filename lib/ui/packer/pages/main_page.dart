import 'package:cash_control/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/blocs/packer_document_bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/blocs/packer_order_bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/packer_order_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/states/packer_order_state.dart';
import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/packer/widgets/order_details_page.dart';
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
              PackerOrdersBloc(baseUrl: baseUrl)..add(FetchPackerOrdersEvent()),
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
          child: BlocBuilder<PackerOrdersBloc, PackerOrdersState>(
            builder: (context, state) {
              if (state is PackerOrdersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PackerOrdersLoaded) {
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
                            if (order['status'] == 'pending')
                              ElevatedButton(
                                style: elevatedButtonStyle,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailsPage(
                                          orderId: order['id']),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Начать',
                                  style: buttonTextStyle, // From constant.dart
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is PackerOrdersError) {
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
