import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alan/constant.dart';
// BLoC
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_receiving_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_receiving_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_receiving_state.dart';

import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_references_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_references_state.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_references_event.dart';

// Your custom widgets
import 'package:alan/ui/storage/widgets/receipt.dart'; // your custom widget for creating a new receipt
import 'package:alan/ui/storage/widgets/edit_receive_dialog.dart';

class GoodsReceiptPage extends StatefulWidget {
  const GoodsReceiptPage({Key? key}) : super(key: key);

  @override
  State<GoodsReceiptPage> createState() => _GoodsReceiptPageState();
}

class _GoodsReceiptPageState extends State<GoodsReceiptPage> {
  @override
  void initState() {
    super.initState();
    // Load references and receipts list
    context.read<StorageReferencesBloc>().add(FetchAllInstancesEvent());
    context.read<StorageReceivingBloc>().add(FetchAllReceiptsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Склад: Приход Товаров', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: BlocConsumer<StorageReceivingBloc, StorageReceivingState>(
        listener: (context, state) {
          if (state is StorageReceivingCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Refresh list after creation
            context.read<StorageReceivingBloc>().add(FetchAllReceiptsEvent());
          } else if (state is StorageReceivingDeleted) {
            // When deletion is successful, show a message and refresh the list
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<StorageReceivingBloc>().add(FetchAllReceiptsEvent());
          } else if (state is StorageReceivingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is StorageReceivingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StorageReceivingListLoaded) {
            final receipts = state.receipts;
            return _buildReceiptsTable(receipts);
          } else if (state is StorageReceivingError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          } else {
            return const Center(
              child: Text('Нет сохранённых поступлений. Нажмите + чтобы добавить.'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _openReceiptDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReceiptsTable(List<dynamic> receipts) {
    if (receipts.isEmpty) {
      return const Center(child: Text('Нет сохранённых поступлений.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(primaryColor),
        columns: [
          DataColumn(label: Text('ID', style: tableHeaderStyle)),
          DataColumn(label: Text('Поставщик', style: tableHeaderStyle)),
          DataColumn(label: Text('Дата', style: tableHeaderStyle)),
          DataColumn(label: Text('Ред.', style: tableHeaderStyle)),
          DataColumn(label: Text('Уд.', style: tableHeaderStyle)),
        ],
        rows: receipts.map<DataRow>((receipt) {
          final id = receipt['id']?.toString() ?? '-';
          final providerName = receipt['provider']?['name'] ?? '-';
          final date = receipt['document_date'] ?? '-';
          return DataRow(cells: [
            DataCell(Text(id, style: tableCellStyle)),
            DataCell(Text(providerName, style: tableCellStyle)),
            DataCell(Text(date, style: tableCellStyle)),
            DataCell(
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () => _onEdit(receipt),
              ),
            ),
            DataCell(
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _onDelete(receipt),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  void _onEdit(dynamic receipt) async {
    final docId = receipt['id'];
    if (docId == null) return;

    await showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<StorageReceivingBloc>(),
          child: EditReceiptDialog(docId: docId),
        );
      },
    );

    // Refresh the list after editing if needed
    context.read<StorageReceivingBloc>().add(FetchAllReceiptsEvent());
  }

  void _onDelete(dynamic receipt) async {
    final docId = receipt['id'];
    if (docId == null) return;

    // Show a confirmation dialog before deletion
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Подтвердите удаление'),
          content: const Text('Вы действительно хотите удалить этот документ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Dispatch the delete event
      context.read<StorageReceivingBloc>().add(DeleteIncomeEvent(docId: docId));

      // Optionally, show a SnackBar immediately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Удаление документа...')),
      );
    }
  }

  // Dialog for creating a new receipt using ReceiptWidget
  Future<void> _openReceiptDialog() async {
    final refState = context.read<StorageReferencesBloc>().state;
    if (refState is! StorageReferencesLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Справочники не загружены.')),
      );
      return;
    }

    final providers = refState.providers;
    final productSubCards = refState.productSubCards;
    final unitMeasurements = refState.unitMeasurements;
    final allExpenses = refState.expenses;

    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: ReceiptWidget(
          providers: providers,
          productSubCards: productSubCards,
          unitMeasurements: unitMeasurements,
          allExpenses: allExpenses,
        ),
      ),
    );

    if (result != null) {
      final newReceiptMap = result as Map<String, dynamic>;
      final newReceiptsList = [newReceiptMap];
      // Create a new receipt
      context.read<StorageReceivingBloc>().add(
        CreateBulkStorageReceivingEvent(receivings: newReceiptsList),
      );
    }
  }
}
