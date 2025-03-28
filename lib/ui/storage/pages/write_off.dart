import 'package:alan/ui/storage/widgets/edit_writeoff_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alan/constant.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/write_off_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/write_off_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/write_off_state.dart';

import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_references_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_references_state.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_references_event.dart';

import 'package:alan/ui/storage/widgets/write_off_widget.dart';

class WriteOffPage extends StatefulWidget {
  const WriteOffPage({Key? key}) : super(key: key);

  @override
  State<WriteOffPage> createState() => _WriteOffPageState();
}

class _WriteOffPageState extends State<WriteOffPage> {
  @override
  void initState() {
    super.initState();
    // We can do this safely now:
    context.read<WriteOffBloc>().add(FetchWriteOffsEvent());
    context.read<StorageReferencesBloc>().add(FetchAllInstancesEvent());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Склад: Списание Товаров', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          // Optionally show a small "references loading" indicator
          _buildReferencesStatus(),
          Expanded(
            child: BlocConsumer<WriteOffBloc, WriteOffState>(
              listener: (context, state) {
                if (state is WriteOffCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Списание создано: ${state.message}')),
                  );
                  // Re-fetch list after creation
                  context.read<WriteOffBloc>().add(FetchWriteOffsEvent());
                } else if (state is WriteOffDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Списание удалено: ${state.message}')),
                  );
                  // Re-fetch list after deletion
                  context.read<WriteOffBloc>().add(FetchWriteOffsEvent());
                } else if (state is WriteOffUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Обновлено: ${state.message}')),
                  );
                  // Re-fetch list after update
                  context.read<WriteOffBloc>().add(FetchWriteOffsEvent());
                } else if (state is WriteOffError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is WriteOffLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is WriteOffListLoaded) {
                  final docs = state.writeOffDocs;
                  return _buildWriteOffTable(docs);
                } else if (state is WriteOffError) {
                  return Center(child: Text('Ошибка: ${state.message}'));
                } else {
                  return const Center(child: Text('Нет данных. Нажмите + для создания.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _openWriteOffDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Optional: display references loading status
  Widget _buildReferencesStatus() {
    return BlocBuilder<StorageReferencesBloc, StorageReferencesState>(
      builder: (context, state) {
        if (state is StorageReferencesLoading) {
          return const LinearProgressIndicator();
        } else if (state is StorageReferencesError) {
          return Text(
            'Справочники: Ошибка: ${state.message}',
            style: const TextStyle(color: Colors.red),
          );
        } else if (state is StorageReferencesLoaded) {
          return const SizedBox();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildWriteOffTable(List<dynamic> docs) {
    if (docs.isEmpty) {
      return const Center(child: Text('Нет сохранённых списаний. Нажмите + для добавления.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(primaryColor),
        columns: [
          DataColumn(label: Text('ID', style: tableHeaderStyle)),
          DataColumn(label: Text('Date', style: tableHeaderStyle)),
          DataColumn(label: Text('Edit', style: tableHeaderStyle)),
          DataColumn(label: Text('Delete', style: tableHeaderStyle)),
        ],
        rows: docs.map<DataRow>((doc) {
          final id = doc['id']?.toString() ?? '-';
          final date = doc['document_date'] ?? '-';
          return DataRow(cells: [
            DataCell(Text(id, style: tableCellStyle)),
            DataCell(Text(date, style: tableCellStyle)),
            DataCell(
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () => _onEdit(doc),
              ),
            ),
            DataCell(
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _onDelete(doc),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Future<void> _openWriteOffDialog() async {
    // Check if references are loaded
    final refState = context.read<StorageReferencesBloc>().state;
    if (refState is! StorageReferencesLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Справочники не загружены. Подождите...')),
      );
      return;
    }

    // Use references as needed
    final units = refState.unitMeasurements;
    final productSubCards = refState.productSubCards;

    final result = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: WriteOffWidget(
          productSubCards: productSubCards,
          unitMeasurements: units,
        ),
      ),
    );

    if (result != null) {
      final payload = result as Map<String, dynamic>;
      // Dispatch creation event
      context.read<WriteOffBloc>().add(CreateWriteOffEvent(payload: payload));
    }
  }

//   void _onEdit(dynamic doc) {
//   final docId = doc['id'];
//   if (docId == null) return;
//   // Open the edit dialog. The dialog itself dispatches FetchSingleWriteOffEvent in initState.
//   showDialog(
//     context: context,
//     builder: (_) => BlocProvider.value(
//       value: context.read<WriteOffBloc>(),
//       child: EditWriteOffDialog(docId: docId),
//     ),
//   );
  
// }
void _onEdit(dynamic doc) async {
  final docId = doc['id'];
  if (docId == null) return;
  
  await showDialog(
    context: context,
    builder: (dialogContext) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<WriteOffBloc>()),
          BlocProvider.value(value: context.read<StorageReferencesBloc>()),
        ],
        child: EditWriteOffDialog(docId: docId),
      );
    },
  );

  // Refresh the list after editing if needed
  context.read<WriteOffBloc>().add(FetchWriteOffsEvent());
}


  void _onDelete(dynamic doc) {
    final docId = doc['id'];
    if (docId == null) return;
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить списание?'),
        content: Text('Вы уверены, что хотите удалить документ #$docId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<WriteOffBloc>().add(DeleteWriteOffEvent(docId: docId));
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
