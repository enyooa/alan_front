import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/operations_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/operations_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/operations_state.dart';
import 'package:cash_control/ui/admin/widgets/refference_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cash_control/constant.dart';

class OperationHistoryPage extends StatefulWidget {
  @override
  _OperationHistoryPageState createState() => _OperationHistoryPageState();
}

class _OperationHistoryPageState extends State<OperationHistoryPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allOperations = []; // Stores all operations fetched
  List<Map<String, dynamic>> filteredOperations = []; // Stores filtered results

  @override
  void initState() {
    super.initState();
    // Fetch operations history on page load
    context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
  }

  void _filterOperations(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredOperations = allOperations;
      });
    } else {
      setState(() {
        filteredOperations = allOperations
            .where((operation) => operation['operation']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'История операций',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink.shade100,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'поиск наименование',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: _filterOperations,
            ),
          ),
          const SizedBox(height: 10),
          // Operations List
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
                    return const Center(
                      child: Text('Нет данных для отображения.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredOperations.length,
                    itemBuilder: (context, index) {
                      final operation = filteredOperations[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  operation['operation'] ?? 'Без названия',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                operation['created_at'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: primaryColor),
                                onPressed: () {
                                  // Navigate to the edit page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditPage(
                                        id: operation['id'],
                                        type: operation['type'], // Specify type
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is OperationsError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
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
