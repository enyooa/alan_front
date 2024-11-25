import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_receiving_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_receiving_state.dart';
import 'package:cash_control/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ProductReceivingPage extends StatefulWidget {
  @override
  _ProductReceivingPageState createState() => _ProductReceivingPageState();
}

class _ProductReceivingPageState extends State<ProductReceivingPage> {
  int? selectedOrganizationId;
  String? organizationAddress;
  List<Map<String, dynamic>> productRows = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // context.read<ProductCardBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поступление товара', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocListener<ProductReceivingBloc, ProductReceivingState>(
        listener: (context, state) {
          if (state is ProductReceivingCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() {
              productRows.clear();
              selectedOrganizationId = null;
              organizationAddress = null;
            });
          } else if (state is ProductReceivingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSupplierDropdownTable(),
              const SizedBox(height: 20),
              // _buildProductTable(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReceivingData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: const Text('Сохранить', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildSupplierDropdownTable() {
    return FutureBuilder<String>(
      future: _getAdminName(), // Fetch the admin's name
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Ошибка загрузки данных администратора'));
        } else {
          return Table(
            border: TableBorder.all(color: borderColor),
            children: [
              TableRow(
                decoration: BoxDecoration(color: primaryColor),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Поставщик', style: tableHeaderStyle),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Дата', style: tableHeaderStyle),
                  ),
                ],
              ),
              TableRow(
                children: [
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Выберите поставщика',
                      labelStyle: formLabelStyle,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    value: selectedOrganizationId,
                    items: [
                      DropdownMenuItem(
                        value: 1, // Static value for admin's ID
                        child: Text(snapshot.data ?? 'Admin', style: bodyTextStyle),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedOrganizationId = value;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            : 'Выберите дату',
                        style: bodyTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  // Helper method to fetch admin's name from SharedPreferences
  Future<String> _getAdminName() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('first_name');
    return firstName ?? 'Admin'; // Default to "Admin" if name not found
  }


  // Widget _buildProductTable() {
  //   return BlocBuilder<ProductCardBloc, ProductCardState>(
  //     builder: (context, state) {
  //       if (state is ProductCardLoading) {
  //         return const Center(child: CircularProgressIndicator());
  //       } else if (state is ProductCardLoaded) {
  //         return Column(
  //           children: [
  //             Table(
  //               border: TableBorder.all(color: borderColor),
  //               children: [
  //                 TableRow(
  //                   decoration: BoxDecoration(color: primaryColor),
  //                   children: const [
  //                     Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Text('Наименование', style: tableHeaderStyle),
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Text('Ед изм', style: tableHeaderStyle),
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Text('Кол-во', style: tableHeaderStyle),
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Text('Цена', style: tableHeaderStyle),
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Text('Сумма', style: tableHeaderStyle),
  //                     ),
  //                   ],
  //                 ),
  //                 ...productRows.map((row) {
  //                   return TableRow(
  //                     children: [
  //                       DropdownButtonFormField<String>(
  //                         decoration: const InputDecoration(border: InputBorder.none),
  //                         value: row['product_card_id'],
  //                         items: state.productCards.map((product) {
  //                           return DropdownMenuItem(
  //                             value: product.id.toString(),
  //                             child: Text(product.nameOfProducts, style: bodyTextStyle),
  //                           );
  //                         }).toList(),
  //                         onChanged: (value) {
  //                           setState(() {
  //                             row['product_card_id'] = value;
  //                           });
  //                         },
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Text(row['unit_measurement'] ?? '', style: tableCellStyle),
  //                       ),
  //                       TextField(
  //                         onChanged: (value) {
  //                           setState(() {
  //                             row['quantity'] = double.tryParse(value) ?? 0;
  //                             row['total_sum'] = (row['quantity'] ?? 0) * (row['price'] ?? 0);
  //                           });
  //                         },
  //                         decoration: const InputDecoration(hintText: 'Кол-во'),
  //                         keyboardType: TextInputType.number,
  //                         style: bodyTextStyle,
  //                       ),
  //                       TextField(
  //                         onChanged: (value) {
  //                           setState(() {
  //                             row['price'] = double.tryParse(value) ?? 0;
  //                             row['total_sum'] = (row['quantity'] ?? 0) * (row['price'] ?? 0);
  //                           });
  //                         },
  //                         decoration: const InputDecoration(hintText: 'Цена'),
  //                         keyboardType: TextInputType.number,
  //                         style: bodyTextStyle,
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Text(row['total_sum'].toString(), style: tableCellStyle),
  //                       ),
  //                     ],
  //                   );
  //                 }).toList(),
  //               ],
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.add),
  //               onPressed: () {
  //                 setState(() {
  //                   productRows.add({
  //                     'product_card_id': null,
  //                     'unit_measurement': '',
  //                     'quantity': 0,
  //                     'price': 0,
  //                     'total_sum': 0,
  //                   });
  //                 });
  //               },
  //             ),
  //           ],
  //         );
  //       } else {
  //         return const Text('Ошибка при загрузке товаров', style: bodyTextStyle);
  //       }
  //     },
  //   );
  // }

  void _submitReceivingData() {
    if (selectedOrganizationId == null || productRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    for (var row in productRows) {
      context.read<ProductReceivingBloc>().add(
            CreateProductReceivingEvent(
              productCardId: int.parse(row['product_card_id']),
              unitMeasurement: row['unit_measurement'],
              quantity: row['quantity'],
              price: row['price'],
              totalSum: row['total_sum'],
            ),
          );
    }
  }
}