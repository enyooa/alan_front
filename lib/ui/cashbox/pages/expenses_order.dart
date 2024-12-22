import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:cash_control/ui/cashbox/widgets/expense_order.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/auth_state.dart';
import 'package:cash_control/constant.dart';

class ExpenseOrderScreen extends StatefulWidget {
  @override
  _ExpenseOrderScreenState createState() => _ExpenseOrderScreenState();
}

class _ExpenseOrderScreenState extends State<ExpenseOrderScreen> {
  Map<int, String> userIdToNameMap = {};

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: pagePadding,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Placeholder for date picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Функция даты будет добавлена')),
                      );
                    },
                    child: Text(
                      'Дата с по',
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
                        child: ExpenseOrderWidget(),
                      ),
                    );
                  },
                  child: Text('Создать', style: buttonTextStyle),
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
                child: BlocBuilder<FinancialOrderBloc, FinancialOrderState>(
                  builder: (context, state) {
                    if (state is FinancialOrderLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (state is FinancialOrderError) {
                      return Center(
                        child: Text(
                          'Ошибка: ${state.message}',
                          style: bodyTextStyle,
                        ),
                      );
                    }
                    if (state is FinancialOrderLoaded) {
                      final expenses = state.financialOrders
                          .where((order) => order['type'] == 'expense')
                          .toList();
                      if (expenses.isEmpty) {
                        return Center(
                          child: Text(
                            'Нет данных для отображения',
                            style: bodyTextStyle,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          final supplierName = userIdToNameMap[int.parse(expense['user_id'].toString())] ??
                              'Неизвестный поставщик';
                          return ExpenseItem(
                            date: expense['date_of_check'] ?? '',
                            supplier: supplierName,
                            amount: expense['summary_cash'].toString(),
                          );
                        },
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final String date;
  final String supplier;
  final String amount;

  const ExpenseItem({
    Key? key,
    required this.date,
    required this.supplier,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: elementPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: subheadingStyle.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(supplier, style: subheadingStyle, textAlign: TextAlign.center),
          ),
          Text(amount, style: subheadingStyle.copyWith(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: primaryColor),
                onPressed: () {
                  // Edit functionality placeholder
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Редактировать $supplier')),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: errorColor),
                onPressed: () {
                  // Delete functionality placeholder
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Удалить $supplier')),
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
