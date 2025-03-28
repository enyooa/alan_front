import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/packer_order_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/packer_order_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/packer_order_state.dart';
import 'package:alan/constant.dart';
import 'package:alan/ui/packer/widgets/order_details_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  /// Looks up the status name from the statuses list by matching statusId.
  String findStatusName(List<Map<String, dynamic>> statuses, int? statusId) {
    if (statusId == null) return 'Неизвестный статус';
    final found = statuses.firstWhere(
      (s) => s['id'] == statusId,
      orElse: () => {},
    );
    return found['name'] ?? 'Неизвестный статус';
  }

  /// Optionally, you can still define a color logic.
  Color getStatusColor(int? statusId) {
    switch (statusId) {
      case 1: return Colors.orange;
      case 2: return Colors.blue;
      case 3: return Colors.cyan;
      case 4: return Colors.green;
      case 5: return Colors.red;
      default: return textColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PackerOrdersBloc(baseUrl: baseUrl)
            ..add(FetchPackerOrdersEvent()),
        ),
        BlocProvider(
          create: (context) => AuthBloc()..add(FetchCourierUsersEvent()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Заявки', style: headingStyle),
          centerTitle: true,
          backgroundColor: primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(horizontalPadding),
          child: BlocBuilder<PackerOrdersBloc, PackerOrdersState>(
            builder: (context, state) {
              if (state is PackerOrdersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PackerOrdersError) {
                return Center(
                  child: Text(
                    'Ошибка: ${state.message}',
                    style: bodyTextStyle.copyWith(color: errorColor),
                  ),
                );
              } else if (state is PackerOrdersLoaded) {
                final orders = state.orders;
                final statuses = state.statuses;

                if (orders.isEmpty) {
                  return const Center(
                    child: Text('Нет доступных заявок', style: bodyTextStyle),
                  );
                }

                // Optionally sort orders so that those with status_id == 4 appear at the bottom
                final sortedOrders = List<Map<String, dynamic>>.from(orders);
                sortedOrders.sort((a, b) {
                  final aStatus = a['status_id'] as int? ?? 0;
                  final bStatus = b['status_id'] as int? ?? 0;
                  if (aStatus == 4 && bStatus != 4) return 1;
                  if (bStatus == 4 && aStatus != 4) return -1;
                  return 0;
                });

                return ListView.builder(
                  itemCount: sortedOrders.length,
                  itemBuilder: (context, index) {
                    final order = sortedOrders[index];
                    final statusId = order['status_id'] as int?;
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
                            // Display order address
                            Text(
                              'Адрес: ${order['address'] ?? 'Не указан'}',
                              style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            // Display status using name from statuses
                            Text(
                              'Статус: $statusName',
                              style: bodyTextStyle.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Display product count if available
                            if (order['order_products'] != null && order['order_products'].isNotEmpty)
                              Text(
                                'Количество продуктов: ${order['order_products'].length}',
                                style: bodyTextStyle,
                              ),
                            const SizedBox(height: 8),
                            // Button for details (navigate to OrderDetailsPage)
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
                              child: const Text('Детали', style: buttonTextStyle),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('Ошибка загрузки заявок.', style: bodyTextStyle),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
