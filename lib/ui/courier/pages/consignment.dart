import 'package:alan/bloc/blocs/courier_page_blocs/blocs/invoice_bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/events/invoice_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/invoice_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/ui/courier/widgets/invoice_details.dart';
import 'package:alan/constant.dart';
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Документы курьера', style: headingStyle),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: BlocProvider(
        create: (context) => InvoiceBloc()..add(FetchInvoiceOrders()),
        child: BlocBuilder<InvoiceBloc, InvoiceState>(
          builder: (context, state) {
            if (state is InvoiceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InvoiceOrdersFetched) {
              final orders = state.orders;

              if (orders.isEmpty) {
                return const Center(
                  child: Text('Нет доступных документов.', style: bodyTextStyle),
                );
              }

              return ListView.builder(
                itemCount: orders.length,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text('Заказ №${order['id']}', style: subheadingStyle),
                      subtitle: Text('Адрес: ${order['address']}', style: bodyTextStyle),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceDetailsPage(order: order),
                            ),
                          );
                        },
                        style: elevatedButtonStyle,
                        child: const Text('Детали', style: buttonTextStyle),
                      ),
                    ),
                  );
                },
              );
            } else if (state is InvoiceError) {
              return Center(
                child: Text('Ошибка: ${state.error}', style: bodyTextStyle),
              );
            }
            return const Center(child: Text('Ошибка загрузки.', style: bodyTextStyle));
          },
        ),
      ),
    );
  }
}
