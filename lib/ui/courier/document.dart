// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cash_control/bloc/blocs/courier_page_blocs/blocs/courier_document_bloc.dart';
// import 'package:cash_control/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
// import 'package:cash_control/bloc/blocs/courier_page_blocs/states/courier_document_state.dart';
// import 'package:cash_control/constant.dart';

// class CourierDocumentsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => CourierDocumentBloc()..add(FetchCourierDocumentsEvent()),
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: primaryColor,
//           title: const Text('Courier Documents', style: headingStyle),
//         ),
//         body: BlocBuilder<CourierDocumentBloc, CourierDocumentState>(
//           builder: (context, state) {
//             if (state is CourierDocumentLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is CourierDocumentLoaded) {
//               return _buildDocumentList(state.documents);
//             } else if (state is CourierDocumentError) {
//               return Center(
//                 child: Text(
//                   'Error: ${state.error}',
//                   style: bodyTextStyle.copyWith(color: errorColor),
//                 ),
//               );
//             } else {
//               return const Center(child: Text('No data available.'));
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildDocumentList(List<Map<String, dynamic>> documents) {
//     return ListView.builder(
//       itemCount: documents.length,
//       itemBuilder: (context, index) {
//         final doc = documents[index];
//         final address = doc['order_items']?.first['order']['address'] ?? 'No Address';
//         final id = doc['id'] ?? 'Unknown ID';

//         return Card(
//           margin: const EdgeInsets.all(8.0),
//           child: ListTile(
//             title: Text('Document ID: $id', style: subheadingStyle),
//             subtitle: Text('Delivery Address: $address', style: bodyTextStyle),
//             trailing: const Icon(Icons.arrow_forward),
//             onTap: () {
//               // Handle document tap, e.g., navigate to details screen
//             },
//           ),
//         );
//       },
//     );
//   }
// }
