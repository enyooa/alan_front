// import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
// import 'package:cash_control/ui/main/models/price_request.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/events/price_request_event.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/states/price_request_state.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/price_request_bloc.dart';
// import 'package:cash_control/bloc/blocs/employee_bloc.dart';
// import 'package:cash_control/bloc/events/employee_event.dart';
// import 'package:cash_control/bloc/states/employee_state.dart';
// import 'package:cash_control/constant.dart';

// class ProductPricingPage extends StatefulWidget {
//   @override
//   _ProductPricingPageState createState() => _ProductPricingPageState();
// }

// class _ProductPricingPageState extends State<ProductPricingPage> {
//   String? selectedClient;
//   String? clientAddress;

//   List<Map<String, dynamic>> productRows = [];

//   @override
//   void initState() {
//     super.initState();
//     context.read<UserBloc>().add(FetchUsersEvent());
//     //context.read<ProductCardBloc>().add(FetchProductCardsEvent());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ценообразование', style: headingStyle),
//         backgroundColor: primaryColor,
//       ),
//       body: BlocListener<PriceRequestBloc, PriceRequestState>(
//         listener: (context, state) {
//           if (state is PriceRequestCreated) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//             setState(() {
//               productRows.clear();
//               selectedClient = null;
//               clientAddress = null;
//             });
//           } else if (state is PriceRequestError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               _buildClientDropdownTable(),
//               const SizedBox(height: 20),
//               _buildProductTable(),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitData,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                 ),
//                 child: const Text('Отправить', style: buttonTextStyle),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildClientDropdownTable() {
//     return BlocBuilder<UserBloc, UserState>(
//       builder: (context, state) {
//         if (state is UserLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (state is UsersLoaded) {
//           final clients = state.users
//               .where((user) => user.roles.any((role) => role.name == 'client'))
//               .toList();

//           return Table(
//             border: TableBorder.all(color: borderColor),
//             children: [
//               TableRow(
//                 decoration: BoxDecoration(color: primaryColor),
//                 children: const [
//                   Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text('Клиент', style: tableHeaderStyle),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text('Адрес клиента', style: tableHeaderStyle),
//                   ),
//                 ],
//               ),
//               TableRow(
//                 children: [
//                   DropdownButtonFormField<String>(
//                     decoration: InputDecoration(
//                       labelText: 'Выберите клиента',
//                       labelStyle: formLabelStyle,
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                     ),
//                     style: bodyTextStyle,
//                     value: selectedClient,
//                     items: clients.map((user) {
//                       return DropdownMenuItem(
//                         value: user.id.toString(),
//                         child: Text('${user.firstName} ${user.lastName}', style: bodyTextStyle),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedClient = value;
//                         clientAddress = clients
//                             .firstWhere((user) => user.id.toString() == value)
//                             .whatsappNumber;
//                       });
//                     },
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(clientAddress ?? '—', style: tableCellStyle),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         } else {
//           return const Text('Ошибка при загрузке клиентов', style: bodyTextStyle);
//         }
//       },
//     );
//   }

// Widget _buildProductTable() {
//   return BlocBuilder<ProductCardBloc, ProductCardState>(
//     builder: (context, state) {
//       if (state is ProductLoading) {
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
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                         ),
//                         value: row['product_card_id'], // Use correct key
//                         items: state.products.map((product) {
//                           return DropdownMenuItem(
//                             value: product.id.toString(),
//                             child: Text(product.nameOfProducts, style: bodyTextStyle),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             row['product_card_id'] = value; // Update correct key
//                           });
//                         },
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(row['unit'] ?? '—', style: tableCellStyle),
//                       ),
//                       TextField(
//                         onChanged: (value) {
//                           setState(() {
//                             row['quantity'] = int.tryParse(value) ?? 0;
//                             row['total'] = row['quantity'] * row['price'];
//                           });
//                         },
//                         decoration: const InputDecoration(hintText: 'Кол-во'),
//                         keyboardType: TextInputType.number,
//                         style: bodyTextStyle,
//                       ),
//                       TextField(
//                         onChanged: (value) {
//                           setState(() {
//                             row['price'] = double.tryParse(value) ?? 0.0;
//                             row['total'] = row['quantity'] * row['price'];
//                           });
//                         },
//                         decoration: const InputDecoration(hintText: 'Цена'),
//                         keyboardType: TextInputType.number,
//                         style: bodyTextStyle,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(row['total'].toString(), style: tableCellStyle),
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
//                     'product_card_id': null, // Use correct key
//                     'unit': null,
//                     'quantity': 0,
//                     'price': 0.0,
//                     'total': 0.0,
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
// void _submitData() {
//   if (selectedClient == null || productRows.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Выберите клиента и заполните таблицу')),
//     );
//     return;
//   }

//   // Map product rows to ProductRequestItem objects
//   final products = productRows.map((row) {
//     return ProductRequestItem(
//       productId: row['product_card_id'].toString(),
//       unitMeasurement: row['unit'] ?? '',
//       amount: row['quantity'] ?? 0,
//       price: row['price'] ?? 0.0,
//     );
//   }).toList();

//   // Construct the PriceRequest
//   final priceRequest = PriceRequest(
//     choiceStatus: 'Pending',
//     userId: selectedClient!,
//     addressId: null, // Replace with actual address ID if needed
//     products: products,
//   );

//   // Dispatch the CreatePriceRequestEvent
//   context.read<PriceRequestBloc>().add(CreatePriceRequestEvent(priceRequest: priceRequest));
// }

// }
