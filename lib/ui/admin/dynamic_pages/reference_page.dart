import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/operations_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/operations_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/operations_state.dart';
import 'package:cash_control/constant.dart';

class OperationHistoryPage extends StatefulWidget {
  @override
  _OperationHistoryPageState createState() => _OperationHistoryPageState();
}

class _OperationHistoryPageState extends State<OperationHistoryPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allOperations = [];
  List<Map<String, dynamic>> filteredOperations = [];

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
                operation['operation']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                operation['type']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История операций'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: _filterOperations,
            ),
          ),
          Expanded(
            child: BlocBuilder<OperationsBloc, OperationsState>(
              builder: (context, state) {
                if (state is OperationsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is OperationsLoaded) {
                  if (allOperations.isEmpty) {
                    allOperations = state.operations;
                    filteredOperations = state.operations;
                  }

                  if (filteredOperations.isEmpty) {
                    return const Center(child: Text('Нет данных для отображения.'));
                  }

                  return ListView.builder(
  itemCount: filteredOperations.length,
  itemBuilder: (context, index) {
    final operation = filteredOperations[index];
    return Card(
      child: ListTile(
        title: Text(
          operation['operation'].toString(), // Ensure it's a string
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Тип: ${operation['type']}'),
        trailing: Text(
          operation['created_at'] ?? '', // No conversion needed if this is already a string
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  },
);


                 } else if (state is OperationsError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('Нет данных.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
