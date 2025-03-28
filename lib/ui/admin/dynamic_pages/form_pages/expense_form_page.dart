// expense_form_page.dart

import 'dart:math';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/expenses_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/expenses_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/expenses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alan/constant.dart';

class ExpenseFormPage extends StatefulWidget {
  const ExpenseFormPage({Key? key}) : super(key: key);

  @override
  _ExpenseFormPageState createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  void _createExpense() {
    final name = _nameController.text.trim();
    final amountStr = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountStr);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите наименование расхода')),
      );
      return;
    }

    context.read<ExpenseBloc>().add(
      CreateExpenseEvent(name: name, amount: amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is ExpenseCreatedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context, true); // close with success
        } else if (state is ExpenseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Создать расход', style: headingStyle),
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

              const Text('Сумма (необязательно)', style: formLabelStyle),
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
                onPressed: _isLoading ? null : _createExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Создать', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
