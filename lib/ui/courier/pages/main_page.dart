import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/blocs/courier_order_bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/events/courier_order_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/courier_order_state.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/blocs/courier_document_bloc.dart'; 
import 'package:alan/ui/Courier/widgets/create_invoice.dart'; 

import 'package:alan/constant.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  /// Find the status name from the fetched statuses
  String findStatusName(List<Map<String, dynamic>> statuses, int? statusId) {
    if (statusId == null) return 'Неизвестный статус';
    // Example: statuses = [{ "id":1, "name":"ожидание" }, ...]
    final found = statuses.firstWhere(
      (s) => s['id'] == statusId,
      orElse: () => {},
    );
    return found['name'] ?? 'Неизвестный статус';
  }

  /// Optionally set color based on status_id or name
  Color getStatusColor(int? statusId) {
    switch (statusId) {
      case 1: return Colors.orange; // ожидание
      case 2: return Colors.blue;   // на фасовке
      case 3: return Colors.cyan;   // доставка
      case 4: return Colors.green;  // исполнено
      default: return textColor;    // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1) Courier Orders
        BlocProvider(
          create: (context) => CourierOrdersBloc(baseUrl: baseUrl)
            ..add(FetchCourierOrdersEvent()),
        ),
        // 2) Auth bloc if needed for courier user data
        BlocProvider(
          create: (context) => AuthBloc()..add(FetchCourierUsersEvent()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Накладные',
            style: headingStyle,
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
              } else if (state is CourierOrdersError) {
                return Center(
                  child: Text(
                    'Ошибка: ${state.message}',
                    style: bodyTextStyle.copyWith(color: errorColor),
                  ),
                );
              } else if (state is CourierOrdersLoaded) {
                // We have both orders & statuses from the backend
                final orders = state.orders;
                final statuses = state.statuses;

                if (orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет доступных заявок',
                      style: bodyTextStyle,
                    ),
                  );
                }

                // Sort so that "исполнено" (status_id=4) are at the bottom
                final sortedOrders = List<Map<String, dynamic>>.from(orders);
                sortedOrders.sort((a, b) {
                  final aStatus = a['status_id'] as int? ?? 0;
                  final bStatus = b['status_id'] as int? ?? 0;
                  // If a is исполнено(4) and b is not => put a lower => bottom
                  if (aStatus == 4 && bStatus != 4) return 1;
                  if (bStatus == 4 && aStatus != 4) return -1;
                  return 0;
                });

                return ListView.builder(
                  itemCount: sortedOrders.length,
                  itemBuilder: (context, index) {
                    final order = sortedOrders[index];
                    final statusId = order['status_id'] as int?;
                    
                    // Use the fetched statuses to get name
                    final statusName = findStatusName(statuses, statusId);
                    final statusColor = getStatusColor(statusId);

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
                            // Address
                            Text(
                              'Адрес: ${order['address'] ?? 'Не указан'}',
                              style: subheadingStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Status
                            Text(
                              'Статус: $statusName',
                              style: bodyTextStyle.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Product count
                            if (order['order_products'] != null &&
                                order['order_products'].isNotEmpty)
                              Text(
                                'Количество продуктов: ${order['order_products'].length}',
                                style: bodyTextStyle,
                              ),
                            const SizedBox(height: 8),
                            // Button design and functionality unchanged
                            ElevatedButton(
                              style: elevatedButtonStyle,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (ctx) => CourierDocumentBloc(),
                                      child: InvoicePage(orderDetails: order),
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'детали накладного',
                                style: buttonTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
}
