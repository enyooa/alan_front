import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // For capturing or selecting photos
import 'dart:io'; // For File handling
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_element.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_element.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/states/financial_element.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/admin_cash_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/states/admin_cash_state.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/auth_state.dart';

import 'package:cash_control/constant.dart';

class IncomeOrderWidget extends StatefulWidget {
  @override
  _IncomeOrderWidgetState createState() => _IncomeOrderWidgetState();
}

class _IncomeOrderWidgetState extends State<IncomeOrderWidget> {
  String? selectedCashAccount;
  String? selectedContractor;
  String? selectedMovementType;
  TextEditingController amountController = TextEditingController();
  File? selectedPhoto; // To hold the selected or captured photo
  final ImagePicker _imagePicker = ImagePicker(); // Image picker instance

  // For selected date range
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    // Fetch users and income categories
    context.read<AuthBloc>().add(FetchClientUsersEvent());
    context.read<ReferenceBloc>().add(FetchReferencesEvent());
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

  // Function to save the financial order
  void _saveFinancialOrder(BuildContext context) {
    if (selectedCashAccount == null ||
        selectedContractor == null ||
        selectedMovementType == null ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заполните все поля', style: bodyTextStyle)),
      );
      return;
    }

    // Prepare the data to submit
    final orderData = {
      'type': 'income',
      'admin_cash_id': selectedCashAccount,
      'user_id': selectedContractor,
      'financial_element_id': selectedMovementType,
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
        title: Text('Создать приходный ордер', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocListener<FinancialOrderBloc, FinancialOrderState>(
        listener: (context, state) {
          if (state is FinancialOrderSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Финансовый ордер сохранен', style: bodyTextStyle)),
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
                BlocBuilder<AdminCashBloc, AdminCashState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (state.errorMessage != null) {
                      return Center(
                        child: Text(
                          state.errorMessage!,
                          style: bodyTextStyle,
                        ),
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
                          value: cashAccount['id'],
                          child: Text(cashAccount['name']!, style: bodyTextStyle),
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
                SizedBox(height: verticalPadding),

                // Contractor Dropdown
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (state is ClientUsersLoaded) {
                      return DropdownButtonFormField<String>(
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
                        items: state.clientUsers.map((contractor) {
                          return DropdownMenuItem<String>(
                            value: contractor['id'].toString(),
                            child: Text(contractor['name'], style: bodyTextStyle),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedContractor = value;
                          });
                        },
                      );
                    } else if (state is AuthError) {
                      return Center(
                          child: Text('Ошибка: ${state.message}', style: bodyTextStyle));
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
                SizedBox(height: verticalPadding),

                // Movement Type Dropdown
                BlocBuilder<ReferenceBloc, ReferenceState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Center(child: CircularProgressIndicator());
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
                      items: movementTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['id'].toString(),
                          child: Text(type['name'], style: bodyTextStyle),
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
                                Text('Загрузить фото', style: bodyTextStyle),
                              ],
                            ),
                    ),
                  ),
                ),
                SizedBox(height: verticalPadding),

                // Save Button
                ElevatedButton(
                  onPressed: () => _saveFinancialOrder(context),
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
