// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:alan/bloc/blocs/organization_bloc.dart';
// import 'package:alan/bloc/events/organization_event.dart';
// import 'package:alan/bloc/states/organization_state.dart';
// import 'package:alan/constant.dart';

// class OrganizationFormPage extends StatefulWidget {
//   @override
//   _OrganizationFormPageState createState() => _OrganizationFormPageState();
// }

// class _OrganizationFormPageState extends State<OrganizationFormPage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController accountController = TextEditingController();

//   void _saveOrganization(BuildContext context) {
//     final name = nameController.text.trim();
//     final accounts = accountController.text.trim();

//     if (name.isEmpty || accounts.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Пожалуйста, заполните все поля')),
//       );
//       return;
//     }

//     // Dispatch the event to save the organization
//     context.read<OrganizationBloc>().add(CreateOrganizationEvent(
//       name: name,
//       currentAccounts: accounts,
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Создать организацию', style: headingStyle),
//         backgroundColor: primaryColor,
//       ),
//       body: BlocConsumer<OrganizationBloc, OrganizationState>(
//         listener: (context, state) {
//           if (state is OrganizationCreated) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Организация успешно создана')),
//             );
//             // Clear the input fields after successful creation
//             nameController.clear();
//             accountController.clear();
//           } else if (state is OrganizationError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is OrganizationLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ListView(
//               children: [
//                 // Organization Name Input Field
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Название',
//                     labelStyle: subheadingStyle,
//                     border: OutlineInputBorder(),
//                   ),
//                   style: bodyTextStyle,
//                 ),
//                 const SizedBox(height: 20),

//                 // Organization Account Input Field
//                 TextField(
//                   controller: accountController,
//                   decoration: const InputDecoration(
//                     labelText: 'Текущие счета',
//                     labelStyle: subheadingStyle,
//                     border: OutlineInputBorder(),
//                   ),
//                   style: bodyTextStyle,
//                 ),
//                 const SizedBox(height: 20),

//                 // Save Button
//                 ElevatedButton(
//                   onPressed: () => _saveOrganization(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                   ),
//                   child: const Text('Сохранить организацию', style: buttonTextStyle),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
