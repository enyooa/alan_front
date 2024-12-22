import 'package:cash_control/bloc/models/operation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/operations_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/operations_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/operations_state.dart';

class OperationHistoryPage extends StatefulWidget {
  @override
  _OperationHistoryPageState createState() => _OperationHistoryPageState();
}

class _OperationHistoryPageState extends State<OperationHistoryPage> {
  final TextEditingController searchController = TextEditingController();
List<Operation> allOperations = [];
List<Operation> filteredOperations = [];


  @override
  void initState() {
    super.initState();
    context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
  }

 void _filterOperations(String query) {
  setState(() {
    if (query.isEmpty) {
      filteredOperations = allOperations;
    } else {
      filteredOperations = allOperations
          .where((operation) =>
              operation.operation.toLowerCase().contains(query.toLowerCase()) ||
              operation.type.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  });
}

  void _editOperation(BuildContext context, Map<String, dynamic> operation) {
    final type = operation['type'];
    switch (type) {
      case 'Продажа':
        _showEditDialog(
          context,
          operation,
          ['количество', 'цена'],
          (fields) {
            context.read<OperationsBloc>().add(
              EditOperationEvent(
                id: int.tryParse(operation['id'].toString()) ?? 0,
                type: 'Продажа',
                updatedFields: {
                  'amount': int.tryParse(fields['amount'] ?? '0') ?? 0,
                  'price': double.tryParse(fields['price'] ?? '0.0') ?? 0.0,
                },
              ),
            );
          },
        );
        break;
      case 'Карточка товара':
        _showEditDialog(
          context,
          operation,
          ['Наименование продукта', 'описание'],
          (fields) {
            context.read<OperationsBloc>().add(
              EditOperationEvent(
                id: int.tryParse(operation['id'].toString()) ?? 0,
                type: 'Карточка товара',
                updatedFields: {
                  'name_of_products': fields['name_of_products'] ?? '',
                  'description': fields['description'] ?? '',
                },
              ),
            );
          },
        );
        break;
      case 'Подкарточка товара':
        _showEditDialog(
          context,
          operation,
          ['название подкарточки', 'брутто', 'нетто'],
          (fields) {
            context.read<OperationsBloc>().add(
              EditOperationEvent(
                id: int.tryParse(operation['id'].toString()) ?? 0,
                type: 'Подкарточка товара',
                updatedFields: {
                  'name': fields['name'] ?? '',
                  'brutto': double.tryParse(fields['brutto'] ?? '0.0') ?? 0.0,
                  'netto': double.tryParse(fields['netto'] ?? '0.0') ?? 0.0,
                },
              ),
            );
          },
        );
        break;
      case 'Ценовое предложение':
        _showEditDialog(
          context,
          operation,
          ['количество', 'цена'],
          (fields) {
            context.read<OperationsBloc>().add(
              EditOperationEvent(
                id: int.tryParse(operation['id'].toString()) ?? 0,
                type: 'Ценовое предложение',
                updatedFields: {
                  'amount': int.tryParse(fields['amount'] ?? '0') ?? 0,
                  'price': double.tryParse(fields['price'] ?? '0.0') ?? 0.0,
                },
              ),
            );
          },
        );
        break;
    }
  }

  void _deleteOperation(BuildContext context, Map<String, dynamic> operation) {
    final type = operation['type'];
    context.read<OperationsBloc>().add(
      DeleteOperationEvent(
        id: int.tryParse(operation['id'].toString()) ?? 0,
        type: type,
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    Map<String, dynamic> operation,
    List<String> fields,
    Function(Map<String, String>) onSave,
  ) {
    final Map<String, TextEditingController> controllers = {
      for (var field in fields)
        field: TextEditingController(text: operation[field]?.toString() ?? ''),
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Редактировать ${operation['type']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields.map((field) {
              return TextField(
                controller: controllers[field],
                decoration: InputDecoration(labelText: field),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final updatedFields = {
                  for (var field in fields) field: controllers[field]?.text ?? '',
                };
                onSave(updatedFields);
                Navigator.pop(context);
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('История операций'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Поиск...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _filterOperations,
          ),
        ),
        Expanded(
          child: BlocConsumer<OperationsBloc, OperationsState>(
  listener: (context, state) {
    if (state is OperationsSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is OperationsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    if (state is OperationsLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is OperationsLoaded) {
      allOperations = state.operations;
      filteredOperations = allOperations;

      if (filteredOperations.isEmpty) {
        return Center(child: Text('Нет данных для отображения.'));
      }

      return ListView.builder(
        itemCount: filteredOperations.length,
        itemBuilder: (context, index) {
          final operation = filteredOperations[index];
          return ListTile(
            title: Text(operation.operation),
            subtitle: Text(operation.type),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editOperation(context, operation.toJson()),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteOperation(context, operation.toJson()),
                ),
              ],
            ),
          );
        },
      );
    } else if (state is OperationsError) {
      return Center(
        child: Text(state.message),
      );
    }
    return Center(
      child: Text('Нет данных.'),
    );
  },
)
),
      ],
    ),
  );
}
}
