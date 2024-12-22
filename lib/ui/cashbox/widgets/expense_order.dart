import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // For capturing or selecting photos
import 'dart:io'; // For File handling
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:cash_control/constant.dart';

class ExpenseOrderWidget extends StatefulWidget {
  @override
  _ExpenseOrderWidgetState createState() => _ExpenseOrderWidgetState();
}

class _ExpenseOrderWidgetState extends State<ExpenseOrderWidget> {
  String? selectedCashAccount;
  String? selectedContractor;
  String? selectedExpenseType;
  TextEditingController amountController = TextEditingController();
  File? selectedPhoto; // To hold the selected or captured photo
  final ImagePicker _imagePicker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    // Fetch necessary data (e.g., cash accounts, contractors, etc.)
    context.read<FinancialOrderBloc>().add(FetchFinancialOrdersEvent());
  }

  // Function to capture or select a photo
  Future<void> _choosePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryColor),
              title: Text('Сделать фото', style: bodyTextStyle),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _imagePicker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    selectedPhoto = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryColor),
              title: Text('Выбрать из галереи', style: bodyTextStyle),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _imagePicker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    selectedPhoto = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Function to save the expense order
  void _saveExpenseOrder(BuildContext context) {
    if (selectedCashAccount == null ||
        selectedContractor == null ||
        selectedExpenseType == null ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заполните все поля', style: bodyTextStyle)),
      );
      return;
    }

    // Prepare the data to submit
    final orderData = {
      'type': 'expense',
      'admin_cash_id': selectedCashAccount,
      'user_id': selectedContractor,
      'financial_element_id': selectedExpenseType,
      'summary_cash': int.tryParse(amountController.text) ?? 0,
      'date_of_check': DateTime.now().toIso8601String(),
      'photo_of_check': selectedPhoto?.path ?? '',
    };

    // Dispatch the event to the bloc
    context.read<FinancialOrderBloc>().add(AddFinancialOrderEvent(orderData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создать расходный ордер', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocListener<FinancialOrderBloc, FinancialOrderState>(
        listener: (context, state) {
          if (state is FinancialOrderSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Расходный ордер сохранен', style: bodyTextStyle)),
            );
            Navigator.pop(context); // Close the modal after saving
          } else if (state is FinancialOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}', style: bodyTextStyle)),
            );
          }
        },
        child: Padding(
          padding: pagePadding,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Cash Account Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'счет кассы . (выбор)',
                    labelStyle: bodyTextStyle,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: selectedCashAccount,
                  items: ['Счет 1', 'Счет 2', 'Счет 3']
                      .map((String account) => DropdownMenuItem<String>(
                            value: account,
                            child: Text(account, style: bodyTextStyle),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCashAccount = value;
                    });
                  },
                ),
                SizedBox(height: verticalPadding),

                // Contractor Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Контрагент (выбор)',
                    labelStyle: bodyTextStyle,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: selectedContractor,
                  items: ['Контрагент 1', 'Контрагент 2', 'Контрагент 3']
                      .map((String contractor) => DropdownMenuItem<String>(
                            value: contractor,
                            child: Text(contractor, style: bodyTextStyle),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedContractor = value;
                    });
                  },
                ),
                SizedBox(height: verticalPadding),

                // Expense Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Статья расхода',
                    labelStyle: bodyTextStyle,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: selectedExpenseType,
                  items: ['Тип расхода 1', 'Тип расхода 2', 'Тип расхода 3']
                      .map((String type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, style: bodyTextStyle),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedExpenseType = value;
                    });
                  },
                ),
                SizedBox(height: verticalPadding),

                // Amount Text Field
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Сумма (вводиться вручную)',
                    labelStyle: bodyTextStyle,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: bodyTextStyle,
                ),
                SizedBox(height: verticalPadding),

                // Photo Upload Section
                GestureDetector(
                  onTap: _choosePhoto,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.blue[100],
                    child: Center(
                      child: selectedPhoto != null
                          ? Image.file(selectedPhoto!, fit: BoxFit.cover)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, color: primaryColor, size: 40),
                                SizedBox(height: 8),
                                Text('здесь фото чека', style: bodyTextStyle),
                              ],
                            ),
                    ),
                  ),
                ),
                SizedBox(height: verticalPadding),

                // Save Button
                ElevatedButton(
                  onPressed: () => _saveExpenseOrder(context),
                  child: Text('Сохранить', style: buttonTextStyle),
                  style: elevatedButtonStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
