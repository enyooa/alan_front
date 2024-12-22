import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/auth_state.dart';
import 'package:cash_control/constant.dart';

class CalculationScreen extends StatefulWidget {
  @override
  _CalculationScreenState createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  Map<int, String> userIdToNameMap = {};

  @override
  void initState() {
    super.initState();
    // Fetch financial orders and user data
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
            // Filter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle date filter action
                  },
                  child: Text(
                    'Дата с по',
                    style: bodyTextStyle.copyWith(color: primaryColor),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: DropdownButton<String>(
                    underline: SizedBox(),
                    hint: Text(
                      'Выбор счета',
                      style: bodyTextStyle,
                    ),
                    items: ['Счет 1', 'Счет 2', 'Счет 3']
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: bodyTextStyle),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      // Handle dropdown selection
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle generate action
                  },
                  style: elevatedButtonStyle,
                  child: Text(
                    'сформировать',
                    style: buttonTextStyle,
                  ),
                ),
              ],
            ),
            Divider(color: borderColor),
            // Table Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              color: Colors.grey[300],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Контрагент', style: subheadingStyle.copyWith(fontWeight: FontWeight.bold)),
                  Text('сумма', style: subheadingStyle.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Table Data Rows
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is ClientUsersLoaded) {
                        _populateUserIdToNameMap(state);
                      }
                    },
                  ),
                ],
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
                      final orders = state.financialOrders;
                      if (orders.isEmpty) {
                        return Center(
                          child: Text(
                            'Нет данных для отображения',
                            style: bodyTextStyle,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final userName = userIdToNameMap[int.tryParse(order['user_id'].toString())] ?? 'Неизвестный клиент';
                          final summaryCash = order['summary_cash']?.toString() ?? '0.00';
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: borderColor),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  userName,
                                  style: bodyTextStyle,
                                ),
                                Text(
                                  summaryCash,
                                  style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ),
            // Export Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.table_chart, color: primaryColor),
                  onPressed: () {
                    // Handle table export action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf, color: primaryColor),
                  onPressed: () {
                    // Handle PDF export action
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
