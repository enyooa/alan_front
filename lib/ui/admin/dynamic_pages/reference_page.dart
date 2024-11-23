import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OperationHistoryPage extends StatefulWidget {
  @override
  _OperationHistoryPageState createState() => _OperationHistoryPageState();
}

class _OperationHistoryPageState extends State<OperationHistoryPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> operations = [];
  List<Map<String, String>> filteredOperations = [];

  @override
  void initState() {
    super.initState();
    // Mock data for demonstration
    operations = [
      {"operation": "Накладная", "timestamp": "2024-11-23 10:45"},
      {"operation": "Накладная", "timestamp": "2024-11-23 11:00"},
      {"operation": "Накладная", "timestamp": "2024-11-23 12:30"},
      {"operation": "Накладная", "timestamp": "2024-11-23 14:15"},
    ];
    filteredOperations = List.from(operations);
  }

  void _filterOperations(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredOperations = List.from(operations);
      });
      return;
    }

    setState(() {
      filteredOperations = operations
          .where((operation) => operation["operation"]!
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История операций', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink.shade100, // Adjust to match the pink background
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
                hintText: 'поиск  наименование',
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
            child: ListView.builder(
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
                            operation["operation"]!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          operation["timestamp"]!,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
