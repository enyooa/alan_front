// import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
// import 'package:cash_control/bloc/blocs/employee_bloc.dart';
// import 'package:cash_control/bloc/events/employee_event.dart';
// import 'package:cash_control/bloc/states/employee_state.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
// import 'package:cash_control/constant.dart';

// class SubProductFormPage extends StatefulWidget {
//   @override
//   _SubProductFormPageState createState() => _SubProductFormPageState();
// }

// class _SubProductFormPageState extends State<SubProductFormPage> {
//   final TextEditingController quantitySoldController = TextEditingController();
//   final TextEditingController priceAtSaleController = TextEditingController();

//   int? selectedProductCardId;
//   int? selectedClientId;

//   @override
//   void initState() {
//     super.initState();
//     context.read<ProductCardBloc>();
//     context.read<UserBloc>().add(FetchUsersEvent());
//   }

//   void _saveSubProduct() {
//     final quantitySold = double.tryParse(quantitySoldController.text.trim());
//     final priceAtSale = double.tryParse(priceAtSaleController.text.trim());

//     if (selectedProductCardId == null || quantitySold == null || priceAtSale == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Пожалуйста, заполните все поля')),
//       );
//       return;
//     }

//     // Dispatch the event to create a sub-product
//     context.read<ProductSubCardBloc>().add(
//           CreateProductSubCardEvent(
//             productCardId: selectedProductCardId!,
//             clientId: selectedClientId,
//             quantitySold: quantitySold,
//             priceAtSale: priceAtSale,
//           ),
//         );
//   }

//   void _clearFields() {
//     selectedProductCardId = null;
//     selectedClientId = null;
//     quantitySoldController.clear();
//     priceAtSaleController.clear();
//     setState(() {});
//   }
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: const Text('Создать Подпродукт', style: headingStyle),
//       backgroundColor: primaryColor,
//     ),
//     body: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ListView(
//         children: [
//           BlocConsumer<ProductSubCardBloc, ProductSubCardState>(
//             listener: (context, state) {
//               if (state is ProductSubCardCreated) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(state.message)),
//                 );
//                 _clearFields();
//               } else if (state is ProductSubCardError) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(state.error)),
//                 );
//               }
//             },
//             builder: (context, state) {
//               return Column(
//                 children: [
//                   // Product Dropdown
//                   BlocBuilder<ProductCardBloc, ProductCardState>(
//                     builder: (context, state) {
//                       if (state is ProductCardLoading) {
//                         return const Center(child: CircularProgressIndicator());
//                       } else if (state is ProductCardLoaded) {
//                         return _buildDropdown(
//                           label: 'Выберите продукт',
//                           items: state.products
//                               .map((product) => {'id': product.id, 'name': product.nameOfProducts})
//                               .toList(),
//                           value: selectedProductCardId,
//                           onChanged: (value) {
//                             setState(() {
//                               selectedProductCardId = value;
//                             });
//                           },
//                         );
//                       }
//                       return const Center(
//                         child: Text('Не удалось загрузить продукты', style: bodyTextStyle),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Client Dropdown
//                   BlocBuilder<UserBloc, UserState>(
//                     builder: (context, state) {
//                       if (state is UserLoading) {
//                         return const Center(child: CircularProgressIndicator());
//                       } else if (state is UsersLoaded) {
//                         final clients = state.users
//                             .where((user) => user.roles.contains('client'))
//                             .map((client) => {
//                                   'id': client.id,
//                                   'name': '${client.firstName} ${client.lastName}'
//                                 })
//                             .toList();
//                         return _buildDropdown(
//                           label: 'Выберите клиента (необязательно)',
//                           items: clients,
//                           value: selectedClientId,
//                           onChanged: (value) {
//                             setState(() {
//                               selectedClientId = value;
//                             });
//                           },
//                         );
//                       }
//                       return const Center(
//                         child: Text('Не удалось загрузить клиентов', style: bodyTextStyle),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Quantity Sold
//                   _buildTextField(quantitySoldController, 'Количество продано'),

//                   // Price At Sale
//                   _buildTextField(priceAtSaleController, 'Цена при продаже'),

//                   const SizedBox(height: 20),

//                   // Save Button
//                   ElevatedButton(
//                     onPressed: _saveSubProduct,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                     ),
//                     child: const Text('Сохранить Подпродукт', style: buttonTextStyle),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     ),
//   );
// }

//   Widget _buildDropdown({
//     required String label,
//     required List<Map<String, dynamic>> items,
//     required int? value,
//     required ValueChanged<int?> onChanged,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: DropdownButtonFormField<int>(
//         value: value,
//         items: items.map((item) {
//           return DropdownMenuItem<int>(
//             value: item['id'],
//             child: Text(item['name'], style: bodyTextStyle),
//           );
//         }).toList(),
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: subheadingStyle,
//           border: const OutlineInputBorder(),
//         ),
//         style: bodyTextStyle,
//         dropdownColor: Colors.white,
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String label) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: subheadingStyle,
//           border: const OutlineInputBorder(),
//         ),
//         keyboardType: TextInputType.number,
//         style: bodyTextStyle,
//       ),
//     );
//   }
// }
