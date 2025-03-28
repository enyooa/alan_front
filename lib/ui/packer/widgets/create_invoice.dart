import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// BLOC imports
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/all_instances_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/all_instances_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/repo/all_instances_repository.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/all_instances_state.dart';

// IMPORTANT: import your existing PackerOrdersBloc files
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/packer_order_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/packer_order_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/packer_order_state.dart';

// CONSTANTS, etc.
import 'package:alan/constant.dart';

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;
  const InvoicePage({Key? key, required this.orderDetails}) : super(key: key);

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  // This holds the user-entered packer_quantities
  late Map<int, double> packerQuantities;

  // Example: chosen courier
  String? selectedCourier;

  @override
  void initState() {
    super.initState();
    // Initialize packerQuantities from the order's "order_products"
    final products = widget.orderDetails['order_products'] ?? [];
    packerQuantities = {
      for (var product in products)
        product['id']: (product['quantity'] ?? 1.0).toDouble(),
    };
  }

  /// Build a request and dispatch SubmitOrderEvent
  void _submitOrder(BuildContext context) {
  final orderId = widget.orderDetails['id'] as int;
  final products = widget.orderDetails['order_products'] ?? [];
  if (products.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Нет продуктов для отправки.')),
    );
    return;
  }

  final List<Map<String, dynamic>> packerItems = [];
  for (var product in products) {
    final pid = product['id'] as int;

    // The quantity the user typed in
    final quantity = packerQuantities[pid] ?? 1.0;

    // Additional fields from product
    final unitMeasurement = product['unit_measurement'] ?? 'шт';
    final price = product['price'] ?? 0;
    final totalSum = (quantity * price).toDouble();

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Невалидное количество для продукта ID=$pid')),
      );
      return;
    }

    packerItems.add({
      'order_item_id': pid,
      'packer_quantity': quantity,
      'unit_measurement': unitMeasurement,
      'price': price,
      'totalsum': totalSum,
    });
  }

  // Dispatch your new "SubmitOrderEvent"
  context.read<PackerOrdersBloc>().add(
    SubmitOrderEvent(
      orderId: orderId,
      products: packerItems, // your backend can read all the fields
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide the AllInstancesBloc for couriers, etc.
        BlocProvider(
          create: (_) => AllInstancesBloc(
            repository: AllInstancesRepository(),
          )..add(FetchAllInstancesEvent()),
        ),
        
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Накладная', style: headingStyle),
          centerTitle: true,
          backgroundColor: primaryColor,
        ),
        // Use a BlocConsumer to both build UI and listen for submission results
        body: BlocConsumer<PackerOrdersBloc, PackerOrdersState>(
          listener: (context, state) {
            // Listen for success or error
            if (state is SubmitOrderLoading) {
              // Could show a loading dialog or something
            } else if (state is SubmitOrderSuccess) {
              // Show success message & maybe navigate away
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Успешно: ${state.message}')),
              );
              Navigator.pop(context); // or stay on the page
            } else if (state is SubmitOrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка: ${state.error}')),
              );
            }
          },
          builder: (context, orderState) {
            // Also build UI for the "AllInstancesBloc" in same builder or nested
            return BlocBuilder<AllInstancesBloc, AllInstancesState>(
              builder: (context, allState) {
                if (allState is AllInstancesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (allState is AllInstancesError) {
                  return Center(
                    child: Text(
                      'Ошибка загрузки данных: ${allState.message}',
                      style: bodyTextStyle.copyWith(color: errorColor),
                    ),
                  );
                } else if (allState is AllInstancesLoaded) {
                  final data = allState.data;
                  final userId = widget.orderDetails['user_id'];
                  final users = data['users'] ?? [];
                  final clientUser = users.firstWhere(
                    (u) => u['id'] == userId,
                    orElse: () => null,
                  );

                  String clientName = 'Неизвестный клиент';
                  if (clientUser != null) {
                    final firstName = clientUser['first_name'] ?? '';
                    final lastName = clientUser['last_name'] ?? '';
                    if (firstName.isNotEmpty || lastName.isNotEmpty) {
                      clientName = '$firstName $lastName'.trim();
                    }
                  }

                  final couriers = data['couriers'] ?? [];

                  return Padding(
                    padding: pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Клиент: $clientName', style: subheadingStyle),
                        const SizedBox(height: verticalPadding),

                        Text(
                          'Адрес доставки: '
                          '${widget.orderDetails['address'] ?? 'Неизвестный адрес'}',
                          style: subheadingStyle,
                        ),
                        const SizedBox(height: verticalPadding),

                        // Product table
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildProductTable(
                              widget.orderDetails['order_products'] ?? [],
                            ),
                          ),
                        ),
                        const SizedBox(height: verticalPadding),

                        // Courier dropdown
                        if (couriers.isEmpty)
                          const Text('Нет доступных курьеров.', style: bodyTextStyle)
                        else
                          DropdownButtonFormField<String>(
                            value: selectedCourier,
                            onChanged: (value) => setState(() => selectedCourier = value),
                            items: couriers.map<DropdownMenuItem<String>>((courier) {
                              final cId = courier['id'].toString();
                              final fName = courier['first_name'] ?? '';
                              final lName = courier['last_name'] ?? '';
                              final courierName = (fName + ' ' + lName).trim();

                              return DropdownMenuItem<String>(
                                value: cId,
                                child: Text(courierName, style: bodyTextStyle),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              labelText: 'Выберите курьера',
                              labelStyle: formLabelStyle,
                              border: OutlineInputBorder(),
                            ),
                          ),

                        const SizedBox(height: verticalPadding),

                        // The "Сохранить накладную" button now calls _submitOrder
                        ElevatedButton(
                          onPressed: () => _submitOrder(context),
                          style: elevatedButtonStyle,
                          child: orderState is SubmitOrderLoading
                              ? const CircularProgressIndicator()
                              : const Text('Сохранить накладную', style: buttonTextStyle),
                        ),
                      ],
                    ),
                  );
                }

                // If AllInstancesState is something else
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductTable(List<dynamic> products) {
    if (products.isEmpty) {
      return const Text('Нет продуктов.', style: bodyTextStyle);
    }

    return Table(
      border: TableBorder.all(color: borderColor),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color: primaryColor),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Наименование', style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Ед. изм.', style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('количество',
                  style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Цена', style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Сумма', style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
          ],
        ),

        // Rows
        for (var product in products)
          TableRow(
            children: [
              // Product name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  product['product_sub_card']?['name'] ?? 'N/A',
                  style: tableCellStyle,
                ),
              ),
              // unit_measurement
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  product['unit_measurement']?.toString() ?? 'N/A',
                  style: tableCellStyle,
                ),
              ),
              // packer_quantity
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue:
                      packerQuantities[product['id']]?.toStringAsFixed(2) ?? '1.00',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'количество фасовки',
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      setState(() {
                        packerQuantities[product['id']] = parsed;
                      });
                    }
                  },
                ),
              ),
              // price
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  (product['price'] ?? 0).toString(),
                  style: tableCellStyle,
                ),
              ),
              // total = packer_quantity * price
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  (
                    (packerQuantities[product['id']] ?? 1.0)
                    * (product['price'] ?? 0)
                  ).toStringAsFixed(2),
                  style: tableCellStyle,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
