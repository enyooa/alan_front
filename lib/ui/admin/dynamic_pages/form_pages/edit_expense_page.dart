// edit_expense_page.dart

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/expenses_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/expenses_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/expenses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:alan/constant.dart';

class EditExpensePage extends StatefulWidget {
  final int expenseId;

  const EditExpensePage({Key? key, required this.expenseId}) : super(key: key);

  @override
  _EditExpensePageState createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _didLoadData = false;

  @override
  void initState() {
    super.initState();
    // 1) fetch single expense
    context.read<ExpenseBloc>().add(
      FetchSingleExpenseEvent(id: widget.expenseId),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final amountStr = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountStr);

    final updatedFields = <String, dynamic>{
      'name': name,
    };
    if (amount != null) {
      updatedFields['amount'] = amount;
    } else {
      // If blank or invalid => could set to null or just omit
      updatedFields['amount'] = null;
    }

    context.read<ExpenseBloc>().add(
      UpdateExpenseEvent(id: widget.expenseId, updatedFields: updatedFields),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseUpdatedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context, true);
        } else if (state is ExpenseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final isLoading = state is ExpenseLoading;

          // Once we get single data
          if (state is SingleExpenseLoaded && !_didLoadData) {
            final expenseData = state.expenseData;
            _nameController.text = expenseData['name'] ?? '';
            if (expenseData['amount'] != null) {
              _amountController.text = expenseData['amount'].toString();
            }
            _didLoadData = true;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Редактировать расход', style: headingStyle),
              backgroundColor: primaryColor,
            ),
            body: SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Наименование расхода', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Сумма', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Сохранить', style: buttonTextStyle),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
