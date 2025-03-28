import 'package:alan/ui/admin/dynamic_pages/form_pages/provider_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Local references
import 'package:alan/constant.dart';
import 'package:alan/bloc/models/operation.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/operations_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/operations_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/operations_state.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/address_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/employee_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';

// *** For expense ***
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/expenses_bloc.dart'; 
import 'package:alan/ui/admin/dynamic_pages/form_pages/expense_form_page.dart';
import 'package:alan/ui/admin/dynamic_pages/form_pages/edit_expense_page.dart';

// Your other forms
import 'package:alan/ui/admin/dynamic_pages/form_pages/product_card_page.dart';
import 'package:alan/ui/admin/dynamic_pages/form_pages/subproduct_card_page.dart';
import 'package:alan/ui/admin/dynamic_pages/form_pages/address_page.dart';
import 'package:alan/ui/admin/dynamic_pages/form_pages/edit_product_card_page.dart';
import 'package:alan/ui/admin/dynamic_pages/form_pages/edit_subcard_page.dart';
import 'package:alan/ui/admin/dynamic_pages/form_pages/unit_form_page.dart';
import 'package:alan/ui/admin/dynamic_pages/form_pages/unit_form_edit_page.dart';
import 'package:alan/ui/admin/dynamic_pages/form_pages/edit_provider_page.dart';

/// Translate possible Russian docType to English code for the backend.
String mapRusToEngDocType(String docTypeRus) {
  switch (docTypeRus) {
    case 'Карточка товара':
      return 'productCard';
    case 'Подкарточка товара':
      return 'subproductCard';
    case 'Ценовое предложение':
      return 'priceOffer';
    case 'Продажа':
      return 'sale';

    case 'Единица измерения':
      return 'unit';
    case 'Ед измерения':
      return 'unit';

    case 'Поставщик':
      return 'provider';
    case 'Адрес':
      return 'address';

    case 'Расход':
      return 'expense';

    default:
      return docTypeRus; // fallback
  }
}

class DynamicFormPage extends StatefulWidget {
  const DynamicFormPage({Key? key}) : super(key: key);

  @override
  _DynamicFormPageState createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedFilter; // docType filter
  List<Operation> _allOperations = [];
  List<Operation> _filteredOperations = [];

  @override
  void initState() {
    super.initState();
    // Fetch operations on init
    context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text('История операций', style: headingStyle),
        backgroundColor: primaryColor,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _onFabPressed,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: pagePadding,
        child: Column(
          children: [
            // Top row: search + filter
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    style: bodyTextStyle,
                    decoration: InputDecoration(
                      hintText: 'Поиск...',
                      hintStyle: captionStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      prefixIcon: const Icon(Icons.search, color: textColor),
                    ),
                    onChanged: _applyFilter,
                  ),
                ),
                const SizedBox(width: 8),

                // Filter dropdown
                Expanded(
                  flex: 1,
                  child: _buildFilterDropdown(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: BlocConsumer<OperationsBloc, OperationsState>(
                listener: (context, state) {
                  if (state is OperationsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message, style: bodyTextStyle),
                        backgroundColor: errorColor,
                      ),
                    );
                  }
                  if (state is OperationsSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message, style: bodyTextStyle),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is OperationsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OperationsLoaded) {
                    // On first load, store local copies
                    if (_allOperations.isEmpty) {
                      _allOperations = state.operations;
                      _filteredOperations = state.operations;
                    }

                    if (_filteredOperations.isEmpty) {
                      return const Center(
                        child: Text(
                          'Нет данных для отображения.',
                          style: bodyTextStyle,
                        ),
                      );
                    }

                    // Show the list
                    return ListView.builder(
                      itemCount: _filteredOperations.length,
                      itemBuilder: (ctx, index) {
                        final op = _filteredOperations[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            tileColor: Colors.white,
                            title: Text(op.operation, style: titleStyle),
                            subtitle: Text(op.type, style: captionStyle),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit
                                IconButton(
                                  icon: const Icon(Icons.edit, color: primaryColor),
                                  onPressed: () => _editOperation(op),
                                ),
                                // Delete
                                IconButton(
                                  icon: const Icon(Icons.delete, color: errorColor),
                                  onPressed: () => _deleteOperation(op),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('Загрузка...', style: bodyTextStyle),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// docType filter dropdown
  Widget _buildFilterDropdown() {
    final docTypeOptions = [
      {'label': 'Все', 'value': null},
      {'label': 'Карточка товара', 'value': 'productCard'},
      {'label': 'Подкарточка товара', 'value': 'subproductCard'},
      {'label': 'Ценовое предложение', 'value': 'priceOffer'},
      {'label': 'Продажа', 'value': 'sale'},
      {'label': 'Ед измерения', 'value': 'unit'},
      {'label': 'Поставщик', 'value': 'provider'},
      {'label': 'Адрес', 'value': 'address'},
      {'label': 'Расход', 'value': 'expense'},
    ];

    return DropdownButtonFormField<String?>(
      value: _selectedFilter,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Фильтр',
        labelStyle: formLabelStyle,
      ),
      items: docTypeOptions.map((opt) {
        return DropdownMenuItem<String?>(
          value: opt['value'] as String?,
          child: Text(opt['label'] as String, style: bodyTextStyle),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedFilter = val;
          _applyFilter('');
        });
      },
    );
  }

  /// Called whenever user types or changes the filter
  void _applyFilter(String? text) {
    final query = text ?? _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredOperations = _allOperations.where((op) {
        final opName = op.operation.toLowerCase();
        final opType = op.type.toLowerCase();

        final matchesType = (_selectedFilter == null) || (op.type == _selectedFilter);
        final matchesText = opName.contains(query) || opType.contains(query);

        return matchesType && matchesText;
      }).toList();
    });
  }

  /// Show the "create" menu
  void _onFabPressed() {
    showModalBottomSheet(
      context: context,
      builder: (_) => _CreateMenu(onSelected: _handleCreateMenuChoice),
    );
  }

  /// The user picks a docType to create
  void _handleCreateMenuChoice(String docType) async {
    Navigator.pop(context);

    switch (docType) {
      case 'productCard':
        {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider(
                create: (_) => ProductCardBloc(),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: ProductCardPage(),
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      case 'subproductCard':
        {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider(
                create: (_) => ProductSubCardBloc(),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: ProductSubCardPage(),
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      case 'unit':
        {
          // CREATE a new unit
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider(
                create: (_) => UnitBloc(),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: UnitFormPage(),
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      case 'provider':
        {
          // CREATE a new provider
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider(
                create: (_) => ProviderBloc(),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: ProviderPage(), // your create provider form
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      case 'address':
        {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<UserBloc>()),
                  BlocProvider(create: (_) => AddressBloc()),
                ],
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: AddressPage(),
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      case 'expense':
        {
          // CREATE expense
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider(
                create: (_) => ExpenseBloc(),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: ExpenseFormPage(), // creation form
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      // For "priceOffer", "sale" => not implemented
      case 'priceOffer':
      case 'sale':
        {
          // Show placeholder
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Создать $docType', style: titleStyle),
              content: Text('(Тут форма для $docType)', style: bodyTextStyle),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx, true);
                    context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
                  },
                  child: const Text('Создать'),
                ),
              ],
            ),
          );
          break;
        }

      default:
        {
          // fallback
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Неизвестный тип'),
              content: Text('Нет формы для типа $docType'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                )
              ],
            ),
          );
        }
    }
  }

  /// The user taps "edit"
  void _editOperation(Operation op) async {
    final engType = mapRusToEngDocType(op.type);

    switch (engType) {
      case 'productCard':
        {
          final productId = op.id;
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider(
                create: (_) => ProductCardBloc(),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: EditProductCardPage(
                    productId: productId,
                    existingPhotoUrl: null,
                  ),
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      case 'subproductCard':
        {
          final subCardId = op.id;
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider(
                create: (_) => ProductSubCardBloc(),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: EditSubCardPage(subCardId: subCardId),
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      case 'unit':
        {
          final unitId = op.id;
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider(
                create: (_) => UnitBloc(),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: EditUnitPage(unitId: unitId),
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      case 'provider':
        {
          final providerId = op.id;
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider(
                create: (_) => ProviderBloc(),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: EditProviderPage(providerId: providerId),
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      case 'expense':
        {
          final expenseId = op.id;
          // We'll do single fetch + patch => "EditExpensePage"
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider(
                create: (_) => ExpenseBloc(),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.9,
                  child: EditExpensePage(expenseId: expenseId),
                ),
              );
            },
          );
          if (result == true) {
            context.read<OperationsBloc>().add(FetchOperationsHistoryEvent());
          }
          break;
        }

      default:
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Edit not implemented for $engType')),
          );
        }
    }
  }

  /// The user taps "delete"
  void _deleteOperation(Operation op) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить?', style: titleStyle),
        content: Text('Точно удалить #${op.id}?', style: bodyTextStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final engType = mapRusToEngDocType(op.type);
      context.read<OperationsBloc>().add(DeleteOperationEvent(
        id: op.id,
        type: engType,
      ));
    }
  }
}

class _CreateMenu extends StatelessWidget {
  final ValueChanged<String> onSelected;
  const _CreateMenu({Key? key, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createItems = [
      {'label': 'Карточка товара', 'value': 'productCard'},
      {'label': 'Подкарточка товара', 'value': 'subproductCard'},
      {'label': 'Единица измерения', 'value': 'unit'},
      {'label': 'Поставщик', 'value': 'provider'},
      {'label': 'Адрес', 'value': 'address'},
      {'label': 'Расход', 'value': 'expense'},
    ];

    return SafeArea(
      child: Wrap(
        children: [
          const ListTile(
            title: Text('Выберите, что создать:', style: bodyTextStyle),
          ),
          ...createItems.map((opt) {
            return ListTile(
              title: Text(opt['label'] as String, style: bodyTextStyle),
              onTap: () => onSelected(opt['value'] as String),
            );
          }).toList(),
        ],
      ),
    );
  }
}
