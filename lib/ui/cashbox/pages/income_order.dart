import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_element.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_element.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/auth_state.dart';
import 'package:cash_control/ui/cashbox/widgets/income_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/constant.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Map<int, String> userIdToNameMap = {};

  @override
  void initState() {
    super.initState();
    // Fetch financial orders and client users
    context.read<FinancialOrderBloc>().add(FetchFinancialOrdersEvent());
    context.read<AuthBloc>().add(FetchClientUsersEvent());

  }

  void _populateUserIdToNameMap(AuthState state) {
    if (state is ClientUsersLoaded) {
      userIdToNameMap = {
        for (var user in state.clientUsers) int.parse(user['id'].toString()): user['name']
      };
    }
  }

  Future<void> _pickDateRange() async {
    // Placeholder for future date range logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Дата выбора временно недоступна')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDateRange,
                    child: Text(
                      'дата с по',
                      style: bodyTextStyle.copyWith(color: textColor),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: textColor,
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: horizontalPadding / 2),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle supplier filter action
                    },
                    child: Text(
                      'поставщик',
                      style: bodyTextStyle.copyWith(color: textColor),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: textColor,
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: horizontalPadding / 2),
                ElevatedButton(
                  onPressed: () {
                    // Open the IncomeOrderWidget as a modal
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: IncomeOrderWidget(),
                      ),
                    );
                  },
                  child: Text(
                    'Создать',
                    style: buttonTextStyle,
                  ),
                  style: elevatedButtonStyle,
                ),
              ],
            ),
            SizedBox(height: verticalPadding),
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is ClientUsersLoaded) {
                  _populateUserIdToNameMap(state);
                }
              },
              child: Expanded(
                child: BlocListener<FinancialOrderBloc, FinancialOrderState>(
              listener: (context, state) {
                if (state is FinancialOrderSaved) {
                  context.read<FinancialOrderBloc>().add(FetchFinancialOrdersEvent());
                }
              },
              child: BlocBuilder<FinancialOrderBloc, FinancialOrderState>(
                builder: (context, state) {
                  if (state is FinancialOrderLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is FinancialOrderError) {
                    return Center(
                      child: Text('Ошибка: ${state.message}', style: bodyTextStyle),
                    );
                  }
                  if (state is FinancialOrderLoaded) {
                    final orders = state.financialOrders;
                    if (orders.isEmpty) {
                      return Center(
                        child: Text('Нет данных для отображения', style: bodyTextStyle),
                      );
                    }
                    return ListView.builder(
  itemCount: orders.length,
  itemBuilder: (context, index) {
    final order = orders[index];
    final supplierName = userIdToNameMap[int.parse(order['user_id'].toString())] ?? 'Неизвестный поставщик';

    return OrderItem(
      orderId: order['id'], // Pass the order ID
      date: order['date_of_check'] ?? '', // Pass the date
      supplier: supplierName, // Pass the supplier name
      amount: order['summary_cash'].toString(), // Pass the amount
      index: index, // Pass the index here
    );
  },
);
}
                  return SizedBox.shrink();
                    },
                  ),
                )
                ),
            ),
          ],
        ),
      ),
    );
  }
}
class OrderItem extends StatelessWidget {
  final String date;
  final String supplier;
  final String amount;
  final int orderId;
  final int index; // Add the index parameter

  const OrderItem({
    Key? key,
    required this.date,
    required this.supplier,
    required this.amount,
    required this.orderId,
    required this.index, // Include the index as a required parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              supplier,
              style: subheadingStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            amount,
            style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: primaryColor),
                onPressed: () {
                  // Handle edit action
                },
              ),
             IconButton(
              icon: Icon(Icons.delete, color: errorColor),
              onPressed: () {
                print('Dispatching DeleteFinancialOrderEvent for order ID: $orderId');
                context.read<FinancialOrderBloc>().add(
                  DeleteFinancialOrderEvent(orderId: orderId),
                );
              },
            ),



            ],
          ),
        ],
      ),
    );
  }
}
