import 'package:alan/ui/packer/widgets/document_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/packer_history_document_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/packer_history_document_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/packer_history_document_state.dart';
import 'package:alan/constant.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  /// Helper: Look up status name from the statuses list.
  String findStatusName(List<Map<String, dynamic>> statuses, int? statusId) {
    if (statusId == null) return 'Неизвестный статус';
    final found = statuses.firstWhere(
      (s) => s['id'] == statusId,
      orElse: () => {},
    );
    return found['name'] ?? 'Неизвестный статус';
  }

  /// Helper: Return a color for the status (still using manual mapping).
  Color getStatusColor(int? statusId) {
    switch (statusId) {
      case 1:
        return Colors.orange; // Ожидание
      case 2:
        return Colors.blue;   // На фасовке
      case 3:
        return Colors.cyan;   // Доставка
      case 4:
        return Colors.green;  // Исполнено
      case 5:
        return Colors.red;    // Отменено
      default:
        return textColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PackerHistoryDocumentBloc(baseUrl: baseUrl)
          ..add(FetchPackerHistoryDocumentsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'История Накладных',
            style: headingStyle,
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
        ),
        body: BlocBuilder<PackerHistoryDocumentBloc, PackerHistoryDocumentState>(
          builder: (context, state) {
            if (state is PackerHistoryDocumentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PackerHistoryDocumentLoaded) {
              final documents = state.documents;
              final statuses = state.statuses; // Fetched statuses from backend

              if (documents.isEmpty) {
                return const Center(
                  child: Text(
                    'Нет доступных заявок в истории',
                    style: bodyTextStyle,
                  ),
                );
              }

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];
                  final int? statusId = document['status_id'] as int?;
                  final statusName = findStatusName(statuses, statusId);
                  final statusColor = getStatusColor(statusId);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Адрес: ${document['address'] ?? 'Не указан'}',
                            style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // Display status using colorful text without a dot.
                          Row(
                            children: [
                              Text('Статус: ', style: bodyTextStyle),
                              Text(
                                statusName,
                                style: bodyTextStyle.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (document['order_products'] != null &&
                              document['order_products'].isNotEmpty)
                            Text(
                              'Количество продуктов: ${document['order_products'].length}',
                              style: bodyTextStyle,
                            ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: elevatedButtonStyle,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryOrderDetailsPage(document: document),
                                ),
                              );
                            },
                            child: const Text(
                              'Детали',
                              style: buttonTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is PackerHistoryDocumentError) {
              return Center(
                child: Text(
                  'Ошибка: ${state.message}',
                  style: bodyTextStyle.copyWith(color: errorColor),
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'Ошибка загрузки истории заявок.',
                  style: bodyTextStyle,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
