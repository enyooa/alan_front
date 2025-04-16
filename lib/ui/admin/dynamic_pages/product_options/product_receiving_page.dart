import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoCs & events/states
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_receiving_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_receiving_event.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/warehouse_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/warehouse_event.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/expenses_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/expenses_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/expenses_event.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/states/provider_state.dart';
import 'package:alan/bloc/blocs/common_blocs/events/provider_event.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';

// Your constants with #0ABCD7->#6CC6DA
import 'package:alan/constant_new_version.dart';

///
/// This page can create OR edit a Product Receiving doc.
/// If [docId] != null, we fetch the doc & references for editing.
/// If [docId] == null, we do the normal "create" flow with separate BLoCs.
///
class ProductReceivingPage extends StatefulWidget {
  final VoidCallback? onClose;
  final int? docId; // If we have a docId => "edit" mode, else "create" mode

  const ProductReceivingPage({
    Key? key,
    this.onClose,
    this.docId,
  }) : super(key: key);

  @override
  State<ProductReceivingPage> createState() => _ProductReceivingPageState();
}

class _ProductReceivingPageState extends State<ProductReceivingPage> {
  DateTime? _selectedDate;
  int? _selectedProviderId;
  int? _selectedWarehouseId;

  /// The product rows
  final List<Map<String, dynamic>> _productRows = [];

  /// The expense rows
  final List<Map<String, dynamic>> _expenseRows = [];

  bool get _isEditMode => widget.docId != null; // docId => editing

  @override
  void initState() {
    super.initState();

    // If docId is present => fetch single doc from ProductReceivingBloc
    if (_isEditMode) {
      context.read<ProductReceivingBloc>().add(
        FetchSingleProductReceivingEvent(widget.docId!), // you'll define this event
      );
    } else {
      // "Create" mode => fetch references from separate BLoCs
      context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
      context.read<UnitBloc>().add(FetchUnitsEvent());
      context.read<ProviderBloc>().add(FetchProvidersEvent());
      context.read<WarehouseBloc>().add(FetchWarehousesEvent());
      context.read<ExpenseBloc>().add(FetchExpensesEvent());

      // Start with 1 blank product row
      _productRows.add({
        'product_subcard_id': null,
        'unit_measurement': null,
        'quantity': 0.0,
        'brutto': 0.0,
        'netto': 0.0,
        'price': 0.0,
        'sum': 0.0,
        'additional_expense': 0.0,
        'cost_price': 0.0,
      });

      // Start with 1 blank expense row
      _expenseRows.add({
        'expenseId': null,
        'amount': 0.0,
        'providerId': null,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          _isEditMode
              ? 'Админ: Редактировать Поступление (ID: ${widget.docId})'
              : 'Админ: Поступление Товара',
          style: const TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              widget.onClose?.call();
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: BlocListener<ProductReceivingBloc, ProductReceivingState>(
        listener: (context, state) {
          // ============= Single Doc Loaded for editing =============
          if (state is ProductReceivingSingleLoaded) {
            // This state includes the doc + references => fill the form
            _initializeFromDoc(state);
          }

          // ============= Successfully Updated =============
          if (state is ProductReceivingUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Then close
            widget.onClose?.call();
            Navigator.pop(context);
          }

          // ============= Created =============
          if (state is ProductReceivingCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Reset local form (only if you want to keep the form open for new entries)
            // Or close
            widget.onClose?.call();
            Navigator.pop(context);
          }

          // ============= Error =============
          if (state is ProductReceivingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Provider + Warehouse + Date
              _buildProviderWarehouseDateRow(),

              const SizedBox(height: 16),
              // We'll show product table
              _buildProductTable(),

              const SizedBox(height: 16),
              // We'll show expenses table
              _buildExpensesTable(),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: _onSave,
                child: Text(
                  _isEditMode ? 'Обновить' : 'Сохранить',
                  style: buttonTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  PART A: If Editing => Fill the Form
  // ============================================================
  void _initializeFromDoc(ProductReceivingSingleLoaded state) {
    // The doc
    final doc = state.document;
    _selectedProviderId = doc['provider_id'] as int?;
    // parse the date
    if (doc['document_date'] != null) {
      _selectedDate = DateTime.tryParse(doc['document_date'].toString());
    }
    // or doc['to_warehouse_id'] or doc['warehouse_id']
    _selectedWarehouseId = doc['to_warehouse_id'] as int?;

    // Build _productRows from doc['document_items']
    final items = doc['document_items'] as List<dynamic>? ?? [];
    _productRows.clear();
    for (final itm in items) {
      _productRows.add({
        'product_subcard_id': itm['product_subcard_id'],
        'unit_measurement': itm['unit_measurement'],
        'quantity': (itm['quantity'] ?? 0).toDouble(),
        'brutto': (itm['brutto'] ?? 0).toDouble(),
        'netto': (itm['netto'] ?? 0).toDouble(),
        'price': (itm['price'] ?? 0).toDouble(),
        'sum': (itm['total_sum'] ?? 0).toDouble(),
        'additional_expense': (itm['additional_expenses'] ?? 0).toDouble(),
        'cost_price': (itm['cost_price'] ?? 0).toDouble(),
      });
    }
    if (_productRows.isEmpty) {
      // If doc had no items, give one blank row
      _productRows.add({
        'product_subcard_id': null,
        'unit_measurement': null,
        'quantity': 0.0,
        'brutto': 0.0,
        'netto': 0.0,
        'price': 0.0,
        'sum': 0.0,
        'additional_expense': 0.0,
        'cost_price': 0.0,
      });
    }

    // Build _expenseRows from doc['expenses']
    final exps = doc['expenses'] as List<dynamic>? ?? [];
    _expenseRows.clear();
    for (final ex in exps) {
      _expenseRows.add({
        'expenseId': ex['name'] ?? 'NoName',
        'amount': (ex['amount'] ?? 0).toDouble(),
        'providerId': ex['provider_id'] ?? null,
      });
    }
    if (_expenseRows.isEmpty) {
      _expenseRows.add({
        'expenseId': null,
        'amount': 0.0,
        'providerId': null,
      });
    }

    // Also fetch references from the state => we won't do sub-bloc fetching now
    // Because we have them in state.providers, state.warehouses, etc.
    // Possibly store them in local variables if you want
    // e.g. _loadedProviders = state.providers;

    setState(() {});
  }

  // ============================================================
  //  PART B: UI for Provider, Warehouse, Date
  // ============================================================
  Widget _buildProviderWarehouseDateRow() {
    return Row(
      children: [
        Expanded(child: _buildProviderDropdown()),
        const SizedBox(width: 8),
        Expanded(child: _buildWarehouseDropdown()),
        const SizedBox(width: 8),
        Expanded(child: _buildDatePickerCard()),
      ],
    );
  }

  Widget _buildProviderDropdown() {
    // If we are in create mode => use ProviderBloc
    // If we are in edit mode => we might have loaded providers from the single doc event
    // For simplicity, always use ProviderBloc to fetch them (which you did in create mode).
    // In edit mode, you may want to have them from ProductReceivingSingleLoaded
    // We'll do a quick approach:
    return BlocBuilder<ProviderBloc, ProviderState>(
      builder: (context, state) {
        if (state is ProviderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProvidersLoaded) {
          final items = state.providers.map<DropdownMenuItem<int>>((p) {
            return DropdownMenuItem<int>(
              value: p.id,
              child: Text(
                p.name,
                style: bodyTextStyle.copyWith(fontSize: 12),
              ),
            );
          }).toList();

          return _buildSizedDropdown<int>(
            label: 'Поставщик',
            value: _selectedProviderId,
            items: items,
            onChanged: (val) => setState(() => _selectedProviderId = val),
          );
        }
        // If we have no data or error => just show some fallback
        return Text('Нет данных о поставщиках', style: bodyTextStyle);
      },
    );
  }

  Widget _buildWarehouseDropdown() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, whState) {
        if (whState is WarehouseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (whState is WarehouseLoaded) {
          final items = whState.warehouses.map<DropdownMenuItem<int>>((w) {
            return DropdownMenuItem<int>(
              value: w['id'],
              child: Text(
                w['name'] ?? 'NoName',
                style: bodyTextStyle.copyWith(fontSize: 12),
              ),
            );
          }).toList();

          return _buildSizedDropdown<int>(
            label: 'Склад',
            value: _selectedWarehouseId,
            items: items,
            onChanged: (val) => setState(() => _selectedWarehouseId = val),
          );
        } else if (whState is WarehouseError) {
          return Text('Ошибка складов: ${whState.message}', style: bodyTextStyle);
        }
        return const Text('Загрузка складов...', style: bodyTextStyle);
      },
    );
  }

  Widget _buildDatePickerCard() {
    return SizedBox(
      height: 36,
      child: GestureDetector(
        onTap: _pickDate,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'Дата'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: bodyTextStyle.copyWith(fontSize: 12),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildSizedDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return SizedBox(
      height: 36,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              items: items,
              onChanged: onChanged,
              hint: Text(label, style: bodyTextStyle.copyWith(fontSize: 12)),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  PART C: Products Table (similar to your existing code)
  // ============================================================
  Widget _buildProductTable() {
    // If create mode => rely on ProductSubCardBloc
    // If edit mode => the doc references might be loaded from single doc event
    // We'll just continue to rely on sub-bloc in create mode, ignoring that in edit mode.
    return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
      builder: (context, subCardState) {
        if (subCardState is ProductSubCardLoading) {
          // If no docId => create mode => show loading
          // If docId => maybe we already have _productRows from single doc
          return const Center(child: CircularProgressIndicator());
        } else if (subCardState is ProductSubCardsLoaded) {
          final subcards = subCardState.productSubCards;

          return BlocBuilder<UnitBloc, UnitState>(
            builder: (context, unitState) {
              if (unitState is UnitLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (unitState is UnitFetchedSuccess) {
                final allUnits = unitState.units;
                // Filter or do something if you want
                return _buildProductTableBody(subcards, allUnits);
              }
              return const Text('Ошибка при загрузке единиц', style: bodyTextStyle);
            },
          );
        }
        // fallback
        return _buildProductTableBody([], []);
      },
    );
  }

  Widget _buildProductTableBody(List<dynamic> subcards, List<dynamic> units) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: accentColor, width: 1.2),
      ),
      child: Padding(
        padding: elementPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Таблица товаров',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          setState(() => _productRows.clear());
                          _recalcAll();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _productRows.add({
                              'product_subcard_id': null,
                              'unit_measurement': null,
                              'quantity': 0.0,
                              'brutto': 0.0,
                              'netto': 0.0,
                              'price': 0.0,
                              'sum': 0.0,
                              'additional_expense': 0.0,
                              'cost_price': 0.0,
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Column(
              children: List.generate(_productRows.length, (i) {
                final row = _productRows[i];

                final nettVal = row['netto'] ?? 0.0;
                final sumVal = row['sum'] ?? 0.0;
                final addExp = row['additional_expense'] ?? 0.0;
                final costPr = row['cost_price'] ?? 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LINE 1
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product
                          _cellBox(
                            label: 'Наименование',
                            flex: 2,
                            child: DropdownButton<int>(
                              value: row['product_subcard_id'] as int?,
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: tableCellStyle,
                              hint: const Text('Товар', style: tableCellStyle),
                              items: subcards.map<DropdownMenuItem<int>>((sc) {
                                return DropdownMenuItem<int>(
                                  value: sc['id'],
                                  child: Text(
                                    sc['name'] ?? 'NoName',
                                    style: tableCellStyle,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => row['product_subcard_id'] = val);
                                _recalcAll();
                              },
                            ),
                          ),

                          // quantity
                          _cellBox(
                            label: 'Кол-во',
                            flex: 1,
                            child: TextField(
                              style: tableCellStyle,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                              ),
                              onChanged: (val) {
                                setState(() => row['quantity'] = double.tryParse(val) ?? 0.0);
                                _recalcAll();
                              },
                            ),
                          ),

                          // Unit
                          _cellBox(
                            label: 'Ед. изм / Тара',
                            flex: 2,
                            child: DropdownButton<String>(
                              value: row['unit_measurement'] as String?,
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: tableCellStyle,
                              hint: const Text('ед.', style: tableCellStyle),
                              items: units.map<DropdownMenuItem<String>>((u) {
                                final double tareVal = (u['tare'] ?? 0).toDouble();
                                final tareLabel = tareVal > 0 ? ' (${tareVal}г)' : '';
                                return DropdownMenuItem<String>(
                                  value: u['name'],
                                  child: Text(
                                    '${u['name']}$tareLabel',
                                    style: tableCellStyle,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => row['unit_measurement'] = val);
                                _recalcAll();
                              },
                            ),
                          ),

                          // Brutto
                          _cellBox(
                            label: 'Брутто',
                            flex: 1,
                            child: Builder(
                              builder: (_) {
                                final chosenUnit = row['unit_measurement'] as String?;
                                final foundUnit = units.firstWhere(
                                  (x) => x['name'] == chosenUnit,
                                  orElse: () => {'tare': 0},
                                );
                                final double tareVal = (foundUnit['tare'] ?? 0).toDouble();
                                final bruttoEnabled = tareVal > 0;

                                return TextField(
                                  style: bruttoEnabled
                                      ? tableCellStyle
                                      : tableCellStyle.copyWith(color: Colors.grey),
                                  keyboardType: TextInputType.number,
                                  enabled: bruttoEnabled,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0.0',
                                  ),
                                  onChanged: (val) {
                                    if (!bruttoEnabled) return;
                                    setState(() => row['brutto'] = double.tryParse(val) ?? 0.0);
                                    _recalcAll();
                                  },
                                );
                              },
                            ),
                          ),

                          // Price
                          _cellBox(
                            label: 'Цена',
                            flex: 1,
                            child: TextField(
                              style: tableCellStyle,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '0.0',
                              ),
                              onChanged: (val) {
                                setState(() => row['price'] = double.tryParse(val) ?? 0.0);
                                _recalcAll();
                              },
                            ),
                          ),

                          // Delete
                          Container(
                            decoration: BoxDecoration(
                              border: Border(left: tableBorderSide),
                            ),
                            padding: const EdgeInsets.only(top: 24),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => _productRows.removeAt(i));
                                _recalcAll();
                              },
                            ),
                          ),
                        ],
                      ),

                      // LINE 2
                      Container(
                        decoration: BoxDecoration(
                          border: Border(top: tableBorderSide),
                        ),
                        child: Row(
                          children: [
                            _calcBox('Нетто', nettVal),
                            _calcBox('Сумма', sumVal),
                            _calcBox('Доп. расход', addExp),
                            _calcBox('Себестоимость', costPr, isLast: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cellBox({required String label, required Widget child, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: tableBorderSide),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: tableCellStyle),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }

  Widget _calcBox(String label, double value, {bool isLast = false}) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: tableBorderSide,
            right: isLast ? tableBorderSide : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: tableCellStyle),
            const SizedBox(height: 4),
            Text(value.toStringAsFixed(2), style: tableCellStyle),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  PART D: Expenses Table
  // ============================================================
  Widget _buildExpensesTable() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, expState) {
        if (expState is ExpenseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (expState is ExpenseError) {
          return Text('Ошибка расходов: ${expState.message}', style: bodyTextStyle);
        } else if (expState is ExpenseLoaded) {
          final allExpenses = expState.expenses;

          // Then nest a ProviderBloc builder to get the list of providers for the row's providerId
          return BlocBuilder<ProviderBloc, ProviderState>(
            builder: (context, provState) {
              if (provState is ProviderLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (provState is ProvidersLoaded) {
                final allProviders = provState.providers;
                return _buildExpensesBody(allExpenses, allProviders);
              } else {
                return const Text('Ошибка загрузки поставщиков', style: bodyTextStyle);
              }
            },
          );
        }
        // Fallback if no data
        return const SizedBox();
      },
    );
  }

  Widget _buildExpensesBody(List<dynamic> allExpenses, List<dynamic> allProviders) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: accentColor, width: 1.2),
      ),
      child: Padding(
        padding: elementPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Доп. расходы',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          setState(() => _expenseRows.clear());
                          _recalcAll();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _expenseRows.add({
                              'expenseId': null,
                              'amount': 0.0,
                              'providerId': null,
                            });
                          });
                          _recalcAll();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Table header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  _tableHeaderCell('Наименование', width: 100),
                  _tableHeaderCell('Поставщик', width: 100),
                  _tableHeaderCell('Сумма', width: 80),
                  _tableHeaderCell('', width: 50),
                ],
              ),
            ),

            // Table body
            Column(
              children: List.generate(_expenseRows.length, (i) {
                final row = _expenseRows[i];
                return Row(
                  children: [
                    // Expense name
                    _tableBodyCell(
                      width: 100,
                      child: DropdownButton<String>(
                        value: row['expenseId'] as String?,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: tableCellStyle,
                        hint: const Text('Выберите', style: tableCellStyle),
                        items: allExpenses.map<DropdownMenuItem<String>>((ex) {
                          final exName = ex['name'] ?? 'NoName';
                          return DropdownMenuItem(
                            value: exName,
                            child: Text(exName, style: tableCellStyle),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => row['expenseId'] = val);
                          _recalcAll();
                        },
                      ),
                    ),

                    // Provider for each row
                    _tableBodyCell(
                      width: 100,
                      child: DropdownButton<int>(
                        value: row['providerId'] as int?,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: tableCellStyle,
                        hint: const Text('Поставщик', style: tableCellStyle),
                        items: allProviders.map<DropdownMenuItem<int>>((p) {
                          return DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(p.name, style: tableCellStyle),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => row['providerId'] = val);
                          _recalcAll();
                        },
                      ),
                    ),

                    // Amount
                    _tableBodyCell(
                      width: 80,
                      child: TextField(
                        style: tableCellStyle,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.0',
                        ),
                        onChanged: (val) {
                          row['amount'] = double.tryParse(val) ?? 0.0;
                          _recalcAll();
                        },
                      ),
                    ),

                    // Delete
                    _tableBodyCell(
                      width: 50,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() => _expenseRows.removeAt(i));
                          _recalcAll();
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String label, {double width = 100}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(right: tableBorderSide),
      ),
      child: Text(label, style: tableHeaderStyle, textAlign: TextAlign.center),
    );
  }

  Widget _tableBodyCell({required Widget child, double width = 100}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          right: tableBorderSide,
          bottom: tableBorderSide,
        ),
      ),
      child: child,
    );
  }

  // ============================================================
  //  PART E: Recalc Logic
  // ============================================================
  void _recalcAll() {
    // sum of expenses
    double totalExp = 0.0;
    for (final er in _expenseRows) {
      totalExp += er['amount'] ?? 0.0;
    }
    // sum of quantity
    double totalQty = 0.0;
    for (final r in _productRows) {
      totalQty += (r['quantity'] ?? 0.0);
    }

    // We might want unit data to find 'tare'
    final unitState = context.read<UnitBloc>().state;
    List<dynamic> allUnits = [];
    if (unitState is UnitFetchedSuccess) {
      allUnits = unitState.units;
    }

    for (final row in _productRows) {
      final chosenUnitName = row['unit_measurement'];
      final foundUnit = allUnits.firstWhere(
        (u) => u['name'] == chosenUnitName,
        orElse: () => {'tare': 0},
      );
      double tareKg = (foundUnit['tare'] ?? 0) / 1000.0;

      double brutto = row['brutto'] ?? 0.0;
      double qty = row['quantity'] ?? 0.0;

      // Netto
      double nett = brutto - (qty * tareKg);
      if (nett < 0) nett = 0;
      row['netto'] = nett;

      double price = row['price'] ?? 0.0;
      double sumVal = nett * price;
      row['sum'] = sumVal;

      double rowAdd = 0.0;
      if (totalQty > 0 && qty > 0) {
        rowAdd = (qty / totalQty) * totalExp;
      }
      row['additional_expense'] = rowAdd;

      double costP = 0.0;
      if (qty > 0) {
        costP = (sumVal + rowAdd) / qty;
      }
      row['cost_price'] = costP;
    }

    setState(() {});
  }

  // ============================================================
  //  PART F: On Save => Either Create or Update
  // ============================================================
  void _onSave() {
    // 1) Build the payload
    final docDate = _selectedDate == null
        ? DateFormat('yyyy-MM-dd').format(DateTime.now())
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final productList = _productRows.map((row) {
      return {
        'product_subcard_id': row['product_subcard_id'] ?? 0,
        'unit_measurement': row['unit_measurement'] ?? 'шт',
        'quantity': row['quantity'] ?? 0.0,
        'brutto': row['brutto'] ?? 0.0,
        'netto': row['netto'] ?? 0.0,
        'price': row['price'] ?? 0.0,
        'total_sum': row['sum'] ?? 0.0,
        'cost_price': row['cost_price'] ?? 0.0,
        'additional_expenses': row['additional_expense'] ?? 0.0,
      };
    }).toList();

    final expenseList = _expenseRows.map((er) {
      return {
        'name': er['expenseId'] ?? 'NoName',
        'amount': er['amount'] ?? 0.0,
        'provider_id': er['providerId'] ?? 0,
      };
    }).toList();

    if (productList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет данных для отправки')),
      );
      return;
    }

    final payload = {
      'provider_id': _selectedProviderId ?? 0,
      'document_date': docDate,
      'warehouse_id': _selectedWarehouseId ?? 0,
      'products': productList,
      'expenses': expenseList,
    };

    // 2) If in "edit" mode => dispatch update event, else => create
    if (_isEditMode) {
      context.read<ProductReceivingBloc>().add(
        UpdateProductReceivingEvent(docId: widget.docId!, updatedData: payload),
      );
    } else {
      context.read<ProductReceivingBloc>().add(
        CreateBulkProductReceivingEvent(receivings: [payload]),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отправка данных...')),
    );
  }
}
