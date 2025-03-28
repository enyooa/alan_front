import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For date formatting if needed

// Blocs & States
import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';

import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/admin_cash_bloc.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/admin_cash_state.dart';

import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/financial_element.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_element.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/financial_element.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/auth_state.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/provider_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/provider_state.dart';

import 'package:alan/constant.dart';

class ExpenseOrderWidget extends StatefulWidget {
  const ExpenseOrderWidget({Key? key}) : super(key: key);

  @override
  _ExpenseOrderWidgetState createState() => _ExpenseOrderWidgetState();
}

class _ExpenseOrderWidgetState extends State<ExpenseOrderWidget> {
  // A) Standard fields
  String? selectedCashAccount;
  String? selectedExpenseType;
  TextEditingController amountController = TextEditingController();

  // B) Unified “Контрагент” field
  String? _selectedCounterparty; // e.g. "client:2" or "provider:15"

  File? selectedPhoto;
  final ImagePicker _imagePicker = ImagePicker();
  DateTime? _selectedDateOfCheck;

  // Temporary storages for merging
  List<Map<String, dynamic>> _tempClients = [];
  List<Map<String, dynamic>> _tempProviders = [];
  List<Map<String, dynamic>> _counterparties = [];

  @override
  void initState() {
    super.initState();
    // 1) Fetch references (expense types)
    context.read<ReferenceBloc>().add(FetchReferencesEvent());

    // 2) Fetch clients (AuthBloc)
    context.read<AuthBloc>().add(FetchClientUsersEvent());

    // 3) Fetch providers (ProviderBloc)
    context.read<ProviderBloc>().add(FetchProvidersEvent());
  }

  @override
  Widget build(BuildContext context) {
    // We use MultiBlocListener so we can merge data from AuthBloc & ProviderBloc
    return MultiBlocListener(
      listeners: [
        // 1) Listen for create expense success/failure
        BlocListener<FinancialOrderBloc, FinancialOrderState>(
          listener: (context, state) {
            if (state is FinancialOrderSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Расходный ордер сохранен', style: bodyTextStyle)),
              );
              Navigator.pop(context); // Close the widget
            } else if (state is FinancialOrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка: ${state.message}', style: bodyTextStyle)),
              );
            }
          },
        ),

        // 2) Listen for ClientUsersLoaded (AuthBloc)
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is ClientUsersLoaded) {
              final clients = state.clientUsers.map((c) => {
                'id': c['id'].toString(),
                'name': c['name'] ?? 'Без имени',
              }).toList();
              _tempClients = clients;
              _tryMergeCounterparties();
            }
          },
        ),

        // 3) Listen for ProvidersLoaded (ProviderBloc)
        BlocListener<ProviderBloc, ProviderState>(
          listener: (context, state) {
            if (state is ProvidersLoaded) {
              final providers = state.providers.map((p) => {
                'id': p.id.toString(),
                'name': p.name ?? 'Без имени',
              }).toList();
              _tempProviders = providers;
              _tryMergeCounterparties();
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Создать расходный ордер', style: headingStyle),
          backgroundColor: primaryColor,
        ),
        body: Padding(
          padding: pagePadding,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 1) Cash Account
                _buildCashAccountDropdown(),

                const SizedBox(height: verticalPadding),

                // 2) Combined Контрагент
                _buildCounterpartyDropdown(),
                const SizedBox(height: verticalPadding),

                // 3) Expense Type
                _buildExpenseTypeDropdown(),
                const SizedBox(height: verticalPadding),

                // 4) Amount
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Сумма (вводиться вручную)',
                    labelStyle: bodyTextStyle,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                  style: bodyTextStyle,
                ),
                const SizedBox(height: verticalPadding),

                // 5) Date
                _buildDateSelector(),
                const SizedBox(height: verticalPadding),

                // 6) Photo upload
                _buildPhotoUploader(),
                const SizedBox(height: verticalPadding),

                // 7) Save Button
                ElevatedButton(
                  onPressed: _saveExpenseOrder,
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

  // ---------------------------------------------------------------------------
  // Merge logic: clients + providers => single _counterparties
  // ---------------------------------------------------------------------------
  void _tryMergeCounterparties() {
    if (_tempClients.isNotEmpty && _tempProviders.isNotEmpty) {
      _counterparties.clear();

      // Add clients
      for (var c in _tempClients) {
        _counterparties.add({
          'id': c['id'],
          'name': c['name'],
          'type': 'client',
        });
      }

      // Add providers
      for (var p in _tempProviders) {
        _counterparties.add({
          'id': p['id'],
          'name': p['name'],
          'type': 'provider',
        });
      }

      setState(() {}); // Rebuild to show in dropdown
    }
  }

  // ---------------------------------------------------------------------------
  // Build: Cash Account Dropdown (from AdminCashBloc)
  // ---------------------------------------------------------------------------
  Widget _buildCashAccountDropdown() {
    return BlocBuilder<AdminCashBloc, AdminCashState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage != null) {
          return Center(child: Text(state.errorMessage!, style: bodyTextStyle));
        }
        final accounts = state.cashAccounts; // e.g. [{"id":1,"name":"..."}, ...]
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Счет кассы (выбор)',
            labelStyle: bodyTextStyle,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          value: selectedCashAccount,
          items: accounts.map((acc) {
            final val = acc['id'].toString();
            final txt = acc['name'] ?? 'Без имени';
            return DropdownMenuItem<String>(
              value: val,
              child: Text(txt, style: bodyTextStyle),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedCashAccount = value),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build: Combined Контрагент (client or provider)
  // ---------------------------------------------------------------------------
  Widget _buildCounterpartyDropdown() {
    if (_counterparties.isEmpty) {
      // Not loaded or merged yet
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Контрагент (Загрузка...)',
          labelStyle: bodyTextStyle,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        items: const [],
        onChanged: null,
      );
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Контрагент (клиент / поставщик)',
        labelStyle: bodyTextStyle,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      value: _selectedCounterparty,
      items: _counterparties.map((cp) {
        // e.g. "client:2"
        final val = "${cp['type']}:${cp['id']}";
        final displayName = cp['name'] ?? 'Без имени';
        final typeLabel = cp['type'] == 'provider' ? 'Поставщик' : 'Клиент';
        return DropdownMenuItem<String>(
          value: val,
          child: Text("$displayName ($typeLabel)", style: bodyTextStyle),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCounterparty = value);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build: Expense Type Dropdown (from ReferenceBloc)
  // ---------------------------------------------------------------------------
  Widget _buildExpenseTypeDropdown() {
    return BlocBuilder<ReferenceBloc, ReferenceState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage != null) {
          return Center(
            child: Text('Ошибка: ${state.errorMessage}', style: bodyTextStyle),
          );
        }
        final expenseTypes = state.references['Статья расходов'] ?? [];
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Тип расхода',
            labelStyle: bodyTextStyle,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          value: selectedExpenseType,
          items: expenseTypes.map<DropdownMenuItem<String>>((type) {
            final idStr = type['id'].toString();
            final nameStr = type['name'] ?? 'Без названия';
            return DropdownMenuItem<String>(
              value: idStr,
              child: Text(nameStr, style: bodyTextStyle),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedExpenseType = value),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build: Date of Check
  // ---------------------------------------------------------------------------
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Дата чека', style: bodyTextStyle),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _pickDateOfCheck,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
    );
  }

  Future<void> _pickDateOfCheck() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfCheck ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfCheck = picked;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build: Photo Upload
  // ---------------------------------------------------------------------------
  Widget _buildPhotoUploader() {
    return GestureDetector(
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
    );
  }

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
                final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
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
                final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
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

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------
  void _saveExpenseOrder() {
    if (selectedCashAccount == null ||
        _selectedCounterparty == null ||
        selectedExpenseType == null ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заполните все поля', style: bodyTextStyle)),
      );
      return;
    }

    // e.g. "provider:15" => [ "provider", "15" ]
    final parts = _selectedCounterparty!.split(':');
    final cType = parts[0]; // "client" or "provider"
    final cIdStr = parts[1];

    final chosenDate = _selectedDateOfCheck ?? DateTime.now();
    final orderData = {
      'type': 'expense',
      'admin_cash_id': selectedCashAccount,
      'financial_element_id': selectedExpenseType,
      'summary_cash': int.tryParse(amountController.text) ?? 0,
      'date_of_check': DateFormat('yyyy-MM-dd').format(chosenDate),

      // Merged "Контрагент" logic
      'counterparty_id': cIdStr,
      'counterparty_type': cType,
    };

    if (selectedPhoto != null) {
      orderData['photo_of_check'] = selectedPhoto!.path;
    }

    context.read<FinancialOrderBloc>().add(AddFinancialOrderEvent(orderData));
  }
}
