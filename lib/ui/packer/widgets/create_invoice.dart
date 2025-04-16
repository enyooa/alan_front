import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// BLoC imports
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/all_instances_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/all_instances_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/repo/all_instances_repository.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/all_instances_state.dart';

// PackerOrdersBloc
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/packer_order_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/packer_order_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/packer_order_state.dart';

// Styles from your new constants (with #0ABCD7 -> #6CC6DA)
import 'package:alan/constant_new_version.dart';
// or 'package:alan/constant.dart' if your new colors are there

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  const InvoicePage({Key? key, required this.orderDetails}) : super(key: key);

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  // Holds user-entered packer_quantities
  late Map<int, double> packerQuantities;

  // Example: chosen courier
  String? selectedCourier;

  @override
  void initState() {
    super.initState();
    // Initialize packerQuantities from order's "order_products"
    final products = widget.orderDetails['order_products'] ?? [];
    packerQuantities = {
      for (var product in products)
        product['id']: (product['quantity'] ?? 1.0).toDouble(),
    };
  }

  /// Called when user presses "Сохранить накладную"
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
      final quantity = packerQuantities[pid] ?? 1.0;

      if (quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Невалидное количество для продукта ID=$pid')),
        );
        return;
      }

      final unitMeasurement = product['unit_measurement'] ?? 'шт';
      final price = product['price'] ?? 0.0;
      final totalSum = (quantity * price).toDouble();

      packerItems.add({
        'order_item_id': pid,
        'packer_quantity': quantity,
        'unit_measurement': unitMeasurement,
        'price': price,
        'totalsum': totalSum,
      });
    }

    context.read<PackerOrdersBloc>().add(
      SubmitOrderEvent(
        orderId: orderId,
        products: packerItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide AllInstancesBloc to fetch couriers, etc.
        BlocProvider(
          create: (_) => AllInstancesBloc(
            repository: AllInstancesRepository(),
          )..add(FetchAllInstancesEvent()),
        ),
      ],
      child: Scaffold(
        // ========== GRADIENT APP BAR (#0ABCD7 -> #6CC6DA) ==========
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          title: const Text('Накладная', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),

        body: BlocConsumer<PackerOrdersBloc, PackerOrdersState>(
          listener: (context, state) {
            if (state is SubmitOrderLoading) {
              // Optionally show a loading UI/indicator
            } else if (state is SubmitOrderSuccess) {
              // Success
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Успешно: ${state.message}')),
              );
              Navigator.pop(context); // or remain on page
            } else if (state is SubmitOrderError) {
              // Error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка: ${state.error}')),
              );
            }
          },
          builder: (context, orderState) {
            // Nested builder for AllInstancesBloc
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
                  // Extract needed data (couriers, users, etc.)
                  final data = allState.data;
                  final userId = widget.orderDetails['user_id'];
                  final users = data['users'] ?? [];
                  final clientUser = users.firstWhere(
                    (u) => u['id'] == userId,
                    orElse: () => null,
                  );

                  String clientName = 'Неизвестный клиент';
                  if (clientUser != null) {
                    final fName = clientUser['first_name'] ?? '';
                    final lName = clientUser['last_name'] ?? '';
                    if (fName.isNotEmpty || lName.isNotEmpty) {
                      clientName = '$fName $lName'.trim();
                    }
                  }

                  final couriers = data['couriers'] ?? [];

                  return Padding(
                    padding: pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ========== Client info ==========
                        Text('Клиент: $clientName', style: subheadingStyle),
                        const SizedBox(height: 10),
                        Text(
                          'Адрес доставки: ${widget.orderDetails['address'] ?? 'Неизвестный адрес'}',
                          style: subheadingStyle,
                        ),
                        const SizedBox(height: 20),

                        // ========== Product table in a Card with gradient header row ==========
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildProductTable(
                              widget.orderDetails['order_products'] ?? [],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ========== Courier dropdown ========== 
                        if (couriers.isEmpty)
                          const Text('Нет доступных курьеров.', style: bodyTextStyle)
                        else
                          DropdownButtonFormField<String>(
                            value: selectedCourier,
                            onChanged: (value) => setState(() => selectedCourier = value),
                            items: couriers.map<DropdownMenuItem<String>>((c) {
                              final cId = c['id'].toString();
                              final fName = c['first_name'] ?? '';
                              final lName = c['last_name'] ?? '';
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

                        const SizedBox(height: 20),

                        // ========== Button: Сохранить накладную ==========
                        ElevatedButton(
                          style: elevatedButtonStyle,
                          onPressed: () => _submitOrder(context),
                          child: orderState is SubmitOrderLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Сохранить накладную', style: buttonTextStyle),
                        ),
                      ],
                    ),
                  );
                }

                // If not loaded or error, show nothing
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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: accentColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Table Header with gradient ========== 
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, accentColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Товары', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // ========== Table Body (Data) ========== 
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(color: borderColor),
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                // Column headers (row)
                TableRow(
                  decoration: const BoxDecoration(color: primaryColor),
                  children: [
                    _tableHeader('Наименование'),
                    _tableHeader('Ед. изм.'),
                    _tableHeader('Кол-во'),
                    _tableHeader('Цена'),
                    _tableHeader('Сумма'),
                  ],
                ),

                // One row per product
                for (var product in products)
                  TableRow(
                    children: [
                      _tableCell(product['product_sub_card']?['name'] ?? 'N/A'),
                      _tableCell(product['unit_measurement']?.toString() ?? 'N/A'),
                      _buildQtyCell(product),
                      _tableCell((product['price'] ?? 0).toString()),
                      _buildSumCell(product),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable header cell
  TableCell _tableHeader(String label) {
    return TableCell(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(label, style: tableHeaderStyle, textAlign: TextAlign.center),
      ),
    );
  }

  // Reusable data cell
  TableCell _tableCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: tableCellStyle),
      ),
    );
  }

  // For the quantity cell (with user-editable textfield)
  TableCell _buildQtyCell(Map<String, dynamic> product) {
    final productId = product['id'] as int?;
    final quantity = (packerQuantities[productId] ?? 1.0).toStringAsFixed(2);

    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          initialValue: quantity,
          keyboardType: TextInputType.number,
          style: tableCellStyle,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Кол-во',
          ),
          onChanged: (val) {
            final parsed = double.tryParse(val);
            if (parsed != null && productId != null) {
              setState(() {
                packerQuantities[productId] = parsed;
              });
            }
          },
        ),
      ),
    );
  }

  // For the sum cell (quantity * price)
  TableCell _buildSumCell(Map<String, dynamic> product) {
    final productId = product['id'] as int?;
    final qty = packerQuantities[productId] ?? 1.0;
    final price = product['price'] ?? 0.0;
    final sum = (qty * price).toStringAsFixed(2);

    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(sum, style: tableCellStyle),
      ),
    );
  }
}
