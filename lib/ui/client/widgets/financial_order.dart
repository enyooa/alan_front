import 'dart:io'; // For File handling
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/admin_cash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // For capturing or selecting photos

// Blocs & States
import 'package:alan/bloc/blocs/client_page_blocs/blocs/financial_order_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/financial_order_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/financial_order_state.dart';

import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/financial_element.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_element.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/financial_element.dart';

// <-- Import your AccountBloc & AccountState
import 'package:alan/bloc/blocs/common_blocs/blocs/account_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/account_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/account_state.dart';

// Styles & constants
import 'package:alan/constant.dart';
// For date formatting (optional)
import 'package:intl/intl.dart';

import '../../../bloc/blocs/cashbox_page_blocs/blocs/admin_cash_bloc.dart';

class FinancialOrderWidget extends StatefulWidget {
  const FinancialOrderWidget({Key? key}) : super(key: key);

  @override
  _IncomeOrderWidgetState createState() => _IncomeOrderWidgetState();
}

class _IncomeOrderWidgetState extends State<FinancialOrderWidget> {
  String? selectedCashAccount;
  String? selectedMovementType;

  final TextEditingController amountController = TextEditingController();

  File? selectedPhoto; // To hold the selected or captured photo
  final ImagePicker _imagePicker = ImagePicker(); // Image picker instance

  DateTime? _selectedDateOfCheck;

  // We'll store the current authenticated user's ID from AccountBloc
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    // We no longer fetch client users, since we want the logged-in user's ID
    // context.read<AuthBloc>().add(FetchClientUsersEvent()); // <--- remove

    // Fetch references for movement types
    context.read<ReferenceBloc>().add(FetchReferencesEvent());

    // Ensure we have user data from AccountBloc
    context.read<AccountBloc>().add(FetchUserData());
  }

  // Choose date for date_of_check
  Future<void> _pickDateOfCheck() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfCheck ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfCheck = picked;
      });
    }
  }

  // Open bottom sheet to choose camera or gallery
  Future<void> _choosePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: primaryColor),
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
              leading: const Icon(Icons.photo_library, color: primaryColor),
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

  // Validate and dispatch the "add financial order" event
  void _saveFinancialOrder(BuildContext context) {
    if (selectedCashAccount == null ||
        selectedMovementType == null ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заполните все поля', style: bodyTextStyle)),
      );
      return;
    }

    if (currentUserId == null) {
      // We haven't loaded the user's ID yet from AccountBloc
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: не найден пользователь', style: bodyTextStyle)),
      );
      return;
    }

    final chosenDate = _selectedDateOfCheck ?? DateTime.now();

    // Prepare the data to submit
    final orderData = {
      'type': 'income',              // or 'expense', if needed
      'admin_cash_id': selectedCashAccount,
      'user_id': currentUserId,      // <--- KEY: Auth user ID
      'financial_element_id': selectedMovementType,
      'summary_cash': int.tryParse(amountController.text) ?? 0,
      'date_of_check': chosenDate.toIso8601String(),
    };

    // If a photo is selected, we pass its path for the BLoC to handle
    if (selectedPhoto != null) {
      orderData['photo_of_check'] = selectedPhoto!.path;
    }

    // Dispatch the event to the bloc
    context.read<FinancialOrderBloc>().add(AddFinancialOrderEvent(orderData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создать приходный ордер', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      // We use MultiBlocListener so we can listen to FinancialOrderBloc & AccountBloc
      body: MultiBlocListener(
        listeners: [
          // Listen for financial order creation success/failure
          BlocListener<FinancialOrderBloc, FinancialOrderState>(
            listener: (context, state) {
              if (state is FinancialOrderSaved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Финансовый ордер сохранен', style: bodyTextStyle)),
                );
                Navigator.pop(context); // Dismiss page after saving
              } else if (state is FinancialOrderError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: ${state.message}', style: bodyTextStyle)),
                );
              }
            },
          ),
          // Listen for AccountLoaded to capture the current user ID
          BlocListener<AccountBloc, AccountState>(
            listener: (context, state) {
              if (state is AccountLoaded) {
                // Ensure your backend returns 'id' in userData
                currentUserId = state.userData['id']?.toString();
              }
            },
          ),
        ],
        child: Padding(
          padding: pagePadding,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Cash Account Dropdown
                BlocBuilder<AdminCashBloc, AdminCashState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.errorMessage != null) {
                      return Center(
                        child: Text(state.errorMessage!, style: bodyTextStyle),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Счет кассы (выбор)',
                        labelStyle: bodyTextStyle,
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: selectedCashAccount,
                      items: state.cashAccounts.map((cashAccount) {
                        return DropdownMenuItem<String>(
                          value: cashAccount['id'].toString(),
                          child: Text(
                            cashAccount['name'] ?? 'Без имени',
                            style: bodyTextStyle,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCashAccount = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: verticalPadding),

                // Movement Type Dropdown (from ReferenceBloc => e.g., income references)
                BlocBuilder<ReferenceBloc, ReferenceState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.errorMessage != null) {
                      return Center(
                        child: Text('Ошибка: ${state.errorMessage}', style: bodyTextStyle),
                      );
                    }
                    final movementTypes = state.references['Статьи движение денег'] ?? [];
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Статья движения',
                        labelStyle: bodyTextStyle,
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: selectedMovementType,
                      items: movementTypes.map<DropdownMenuItem<String>>((type) {
                        final idStr = type['id'].toString();
                        final nameStr = type['name'] ?? 'Без названия';
                        return DropdownMenuItem<String>(
                          value: idStr,
                          child: Text(nameStr, style: bodyTextStyle),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMovementType = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: verticalPadding),

                // Amount Text Field
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Сумма (ввод)',
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
                const SizedBox(height: verticalPadding),

                // Date of Check
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Дата чека', style: bodyTextStyle),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _pickDateOfCheck,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDateOfCheck == null
                                    ? 'Выберите дату'
                                    : DateFormat('yyyy-MM-dd').format(_selectedDateOfCheck!),
                                style: bodyTextStyle,
                              ),
                              const Icon(Icons.calendar_today, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: verticalPadding),

                // Photo Upload
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
                                const Icon(Icons.upload_file, color: primaryColor, size: 40),
                                const SizedBox(height: 8),
                                Text('Загрузить фото', style: bodyTextStyle),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: verticalPadding),

                // Save Button
                ElevatedButton(
                  onPressed: () => _saveFinancialOrder(context),
                  style: elevatedButtonStyle,
                  child: const Text('Сохранить', style: buttonTextStyle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
