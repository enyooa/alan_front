import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:cash_control/ui/cashbox/widgets/expense_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/constant.dart';

class ExpenseOrderScreen extends StatefulWidget {
  @override
  _ExpenseOrderScreenState createState() => _ExpenseOrderScreenState();
}

class _ExpenseOrderScreenState extends State<ExpenseOrderScreen> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    // Trigger fetching expense orders on page load
    context.read<FinancialOrderBloc>().add(FetchFinancialOrdersEvent());
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
          children: [
            // Filter Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDateRange,
                    child: Text(
                      startDate != null && endDate != null
                          ? '${startDate!.toLocal().toString().split(' ')[0]} - ${endDate!.toLocal().toString().split(' ')[0]}'
                          : 'дата с по',
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
                    // Navigate to the create expense order widget
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
                  child: Text(
                    'Создать',
                    style: buttonTextStyle,
                  ),
                  style: elevatedButtonStyle,
                ),
              ],
            ),
            SizedBox(height: verticalPadding),

            // Expense List
            Expanded(
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
                    final expenses = state.financialOrders;
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
                        return expense['type']=='expense'? ExpenseItem(
                          date: expense['date_of_check'] ?? '',
                          supplier: expense['user_id']?.toString() ?? 'Неизвестный поставщик',
                          amount: expense['summary_cash'].toString(),
                        ):null;
                      },
                    );
                  }
                  return SizedBox.shrink();
                },
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
    required this.date,
    required this.supplier,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: elementPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date
          Text(
            date,
            style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          // Supplier
          Expanded(
            child: Text(
              supplier,
              style: subheadingStyle,
              textAlign: TextAlign.center,
            ),
          ),
          // Amount
          Text(
            amount,
            style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: primaryColor),
                onPressed: () {
                  // Handle edit action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit action for $supplier')),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: errorColor),
                onPressed: () {
                  // Handle delete action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete action for $supplier')),
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
