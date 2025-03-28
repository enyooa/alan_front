import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// BLoCs
import 'package:alan/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/states/auth_state.dart';
import 'package:alan/bloc/blocs/common_blocs/events/auth_event.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/states/provider_state.dart';
import 'package:alan/bloc/blocs/common_blocs/events/provider_event.dart';

import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
// UI
import 'package:alan/ui/cashbox/widgets/expense_order.dart';
import 'package:alan/constant.dart';

class ExpenseOrderScreen extends StatefulWidget {
  const ExpenseOrderScreen({Key? key}) : super(key: key);

  @override
  _ExpenseOrderScreenState createState() => _ExpenseOrderScreenState();
}

class _ExpenseOrderScreenState extends State<ExpenseOrderScreen> {
  // Maps
  final Map<int, String> userIdToNameMap = {};
  final Map<int, String> providerIdToNameMap = {};

  @override
  void initState() {
    super.initState();
    // 1) fetch "expense" orders
    context.read<FinancialOrderBloc>().add(FetchFinancialOrdersEvent());

    // 2) fetch clients + providers
    context.read<AuthBloc>().add(FetchClientUsersEvent());
    context.read<ProviderBloc>().add(FetchProvidersEvent());
  }

  // Fill user map
  void _populateUserIdToNameMap(ClientUsersLoaded state) {
    for (var user in state.clientUsers) {
      final id = int.tryParse(user['id'].toString()) ?? -1;
      final name = user['name'] ?? 'Без имени';
      userIdToNameMap[id] = name;
    }
  }

  // Fill provider map
  void _populateProviderIdToNameMap(ProvidersLoaded state) {
    for (var provider in state.providers) {
      final id = provider.id ?? -1;
      final name = provider.name ?? 'Без имени';
      providerIdToNameMap[id] = name;
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
            // e.g. date filter
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Функция даты будет добавлена')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: textColor,
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Дата с по', style: bodyTextStyle.copyWith(color: textColor)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: verticalPadding),

            // Listen for client + provider data
            MultiBlocListener(
              listeners: [
                BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is ClientUsersLoaded) {
                      _populateUserIdToNameMap(state);
                      setState(() {});
                    }
                  },
                ),
                BlocListener<ProviderBloc, ProviderState>(
                  listener: (context, state) {
                    if (state is ProvidersLoaded) {
                      _populateProviderIdToNameMap(state);
                      setState(() {});
                    }
                  },
                ),
              ],
              child: Expanded(
                child: BlocBuilder<FinancialOrderBloc, FinancialOrderState>(
                  builder: (context, state) {
                    if (state is FinancialOrderLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is FinancialOrderError) {
                      return Center(
                        child: Text('Ошибка: ${state.message}', style: bodyTextStyle),
                      );
                    }
                    if (state is FinancialOrderLoaded) {
                      // filter "expense"
                      final expenses = state.financialOrders
                          .where((order) => order['type'] == 'expense')
                          .toList();

                      if (expenses.isEmpty) {
                        return Center(
                          child: Text('Нет данных для отображения', style: bodyTextStyle),
                        );
                      }

                      return ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];

                          final providerIdRaw = expense['provider_id'];
                          final userIdRaw     = expense['user_id'];

                          String supplierName;
                          String typeLabel;

                          if (providerIdRaw != null) {
                            final pid = int.tryParse(providerIdRaw.toString()) ?? -1;
                            supplierName = providerIdToNameMap[pid] ?? 'Неизвестный поставщик';
                            typeLabel = 'Поставщик';
                          } else {
                            final uid = int.tryParse(userIdRaw.toString()) ?? -1;
                            supplierName = userIdToNameMap[uid] ?? 'Неизвестный клиент';
                            typeLabel = 'Клиент';
                          }

                          final dateStr   = expense['date_of_check']?.toString() ?? '';
                          final amountStr = expense['summary_cash']?.toString() ?? '0';
                          final orderId   = expense['id'];

                          return ExpenseItem(
                            date: dateStr,
                            supplier: "$supplierName ($typeLabel)",
                            amount: amountStr,
                            orderId: orderId,
                            index: index,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // FAB => open ExpenseOrderWidget
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: backgroundColor),
        backgroundColor: primaryColor,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: const ExpenseOrderWidget(),
            ),
          );
        },
      ),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final String date;
  final String supplier;
  final String amount;
  final int orderId;
  final int index;

  const ExpenseItem({
    Key? key,
    required this.date,
    required this.supplier,
    required this.amount,
    required this.orderId,
    required this.index,
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
                icon: const Icon(Icons.edit, color: primaryColor),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Редактировать $supplier')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: errorColor),
                onPressed: () {
                  context.read<FinancialOrderBloc>().add(DeleteFinancialOrderEvent(orderId: orderId));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
