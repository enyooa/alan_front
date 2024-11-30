import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/operations_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/operations_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cash_control/constant.dart';

class EditPage extends StatefulWidget {
  final int id;
  final String type;

  const EditPage({Key? key, required this.id, required this.type})
      : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOperationDetails();
  }

  void _loadOperationDetails() async {
    setState(() {
      isLoading = true;
    });

    // Call an API or Bloc to fetch details for `widget.id`
    final operationDetails = await _fetchOperationDetails(widget.id);

    if (operationDetails != null) {
      nameController.text = operationDetails['operation'] ?? '';
      dateController.text = operationDetails['created_at'] ?? '';
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<Map<String, dynamic>?> _fetchOperationDetails(int id) async {
    // Mock API call (replace with actual API call)
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    return {
      'operation': 'Test Operation',
      'created_at': '2024-11-30 10:00',
    };
  }

  void _submitChanges() {
    if (nameController.text.isEmpty || dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Все поля должны быть заполнены')),
      );
      return;
    }

    context.read<OperationsBloc>().add(UpdateOperationEvent(
          id: widget.id,
          operation: nameController.text,
          date: dateController.text,
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Операция обновлена')),
    );

    Navigator.pop(context); // Return to the previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Редактировать операцию',
          style: headingStyle,
        ),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Наименование операции',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Дата операции',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        dateController.text =
                            '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}';
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.all(12.0),
                    ),
                    child: const Text('Сохранить изменения', style: buttonTextStyle),
                  ),
                ],
              ),
            ),
    );
  }
}
