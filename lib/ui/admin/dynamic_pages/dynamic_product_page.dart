import 'package:alan/bloc/blocs/admin_page_blocs/blocs/transfer_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/expenses_event.dart';
import 'package:alan/ui/admin/dynamic_pages/product_options/transfer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// BLoC for Documents listing
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/docs_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/docs_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/docs_state.dart';

// Additional BLoCs needed for “income”, “write-off”, “transfer”
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/write_off_bloc.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/expenses_bloc.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';

// Their events
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:alan/bloc/blocs/common_blocs/events/provider_event.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/warehouse_event.dart';

// Model
import 'package:alan/bloc/models/doc_item.dart';

// Pages
import 'package:alan/ui/admin/dynamic_pages/product_options/product_receiving_page.dart';
import 'package:alan/ui/admin/dynamic_pages/product_options/write_off_widget.dart';

// Styles / Constants
import 'package:alan/constant.dart';

/// This page displays a list of documents (Docs) and a FAB menu
/// for creating new "income", "write_off", "transfer", etc.
class DynamicProductPage extends StatelessWidget {
  const DynamicProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the DocsBloc so we can fetch & display documents
    return BlocProvider<DocsBloc>(
      create: (_) => DocsBloc()..add(FetchDocsEvent()),
      child: const DynamicDocsView(),
    );
  }
}

class DynamicDocsView extends StatefulWidget {
  const DynamicDocsView({Key? key}) : super(key: key);

  @override
  State<DynamicDocsView> createState() => _DynamicDocsViewState();
}

class _DynamicDocsViewState extends State<DynamicDocsView> {
  // Filters for doc type & search query
  String searchQuery = '';
  String? selectedDocType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Операции (Docs)', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      backgroundColor: backgroundColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _onFabPressed,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: pagePadding,
        child: Column(
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(child: _buildDocsList()),
          ],
        ),
      ),
    );
  }

  /// Filters: doc type dropdown & search textfield
  Widget _buildFilters() {
    final docTypeOptions = [
      {'label': 'Все типы', 'value': null, 'icon': FontAwesomeIcons.boxesPacking},
      {'label': 'Приход', 'value': 'income', 'icon': FontAwesomeIcons.arrowDown},
      // {'label': 'Продажа', 'value': 'sale', 'icon': FontAwesomeIcons.cashRegister},
      {'label': 'Списание', 'value': 'write_off', 'icon': FontAwesomeIcons.trash},
      {'label': 'Перемещение', 'value': 'transfer', 'icon': FontAwesomeIcons.truckFast},
      // {'label': 'Цен. предложение', 'value': 'priceOffer', 'icon': FontAwesomeIcons.tags},
      // {'label': 'Инвентаризация', 'value': 'inventory', 'icon': FontAwesomeIcons.clipboardCheck},
    ];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String?>(
            value: selectedDocType,
            items: docTypeOptions.map((option) {
              return DropdownMenuItem<String?>(
                value: option['value'] as String?,
                child: Row(
                  children: [
                    FaIcon(option['icon'] as IconData, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(option['label'] as String, style: bodyTextStyle),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedDocType = val),
            decoration: InputDecoration(
              labelText: 'Тип документа',
              labelStyle: formLabelStyle,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            style: bodyTextStyle,
            dropdownColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          flex: 3,
          child: TextField(
            style: bodyTextStyle,
            decoration: InputDecoration(
              hintText: 'Поиск...',
              hintStyle: captionStyle,
              labelText: 'Поиск',
              labelStyle: formLabelStyle,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
        ),
      ],
    );
  }

  /// The main docs list
  Widget _buildDocsList() {
    return BlocBuilder<DocsBloc, DocsState>(
      builder: (context, state) {
        if (state is DocsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DocsError) {
          return Center(
            child: Text('Ошибка: ${state.message}', style: bodyTextStyle.copyWith(color: errorColor)),
          );
        } else if (state is DocsLoaded) {
          final filtered = _filterDocs(state.docs, searchQuery, selectedDocType);
          return _buildDocsTable(filtered);
        } else {
          return const Center(child: Text('Загрузка...', style: bodyTextStyle));
        }
      },
    );
  }

  List<DocItem> _filterDocs(List<DocItem> docs, String query, String? docType) {
    var filtered = docs;
    // Filter by doc type
    if (docType != null && docType.isNotEmpty) {
      filtered = filtered.where((d) => d.type == docType).toList();
    }

    // Filter by search query
    if (query.isEmpty) return filtered;
    final lowerQ = query.toLowerCase();

    return filtered.where((doc) {
      final docIdStr = doc.docId.toString().toLowerCase();
      final docNumStr = (doc.documentNumber ?? '').toLowerCase();
      final typeStr = doc.type.toLowerCase();
      final providerStr = (doc.providerName ?? '').toLowerCase();
      final dateStr = doc.documentDate.toLowerCase();

      return docIdStr.contains(lowerQ) ||
          docNumStr.contains(lowerQ) ||
          typeStr.contains(lowerQ) ||
          providerStr.contains(lowerQ) ||
          dateStr.contains(lowerQ);
    }).toList();
  }

  Widget _buildDocsTable(List<DocItem> docs) {
    if (docs.isEmpty) {
      return const Text('Нет документов', style: bodyTextStyle);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(primaryColor),
        columns: const [
          DataColumn(label: Text('№ Документа', style: tableHeaderStyle)),
          DataColumn(label: Text('Тип', style: tableHeaderStyle)),
          DataColumn(label: Text('Дата', style: tableHeaderStyle)),
          DataColumn(label: Text('Поставщик', style: tableHeaderStyle)),
          DataColumn(label: Text('Итог', style: tableHeaderStyle)),
          DataColumn(label: Text('Действия', style: tableHeaderStyle)),
        ],
        rows: docs.map((doc) {
          final docNumber = doc.documentNumber ?? doc.docId.toString();
          return DataRow(cells: [
            DataCell(Text(docNumber, style: bodyTextStyle)),
            DataCell(Text(_mapTypeLabel(doc.type), style: bodyTextStyle)),
            DataCell(Text(_formatDate(doc.documentDate), style: bodyTextStyle)),
            DataCell(Text(doc.providerName ?? '-', style: bodyTextStyle)),
            DataCell(Text(doc.docTotalSum.toStringAsFixed(2), style: bodyTextStyle)),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: primaryColor,
                  onPressed: () => _editDoc(doc),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: errorColor,
                  onPressed: () => _deleteDoc(doc),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  /// The FAB menu to choose doc type
  void _onFabPressed() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            // Income
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Приход'),
              onTap: () {
                Navigator.pop(ctx);
                _openProductReceivingSheet();
              },
            ),
            // Write-Off
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Списание'),
              onTap: () {
                Navigator.pop(ctx);
                _openWriteOffSheet();
              },
            ),
            // Продажа
            // ListTile(
            //   leading: const Icon(Icons.sell),
            //   title: const Text('Продажа (sale)'),
            //   onTap: () {
            //     Navigator.pop(ctx);
            //     _showSimpleCreateDialog('sale');
            //   },
            // ),
            // Перемещение
            ListTile(
              leading: const Icon(Icons.sync_alt),
              title: const Text('Перемещение'),
              onTap: () {
                Navigator.pop(ctx);
                _openTransferSheet();
              },
            ),
            // Цен. предложение
            // ListTile(
            //   leading: const Icon(Icons.price_change),
            //   title: const Text('Цен. предложение (priceOffer)'),
            //   onTap: () {
            //     Navigator.pop(ctx);
            //     _showSimpleCreateDialog('priceOffer');
            //   },
            // ),
            // Инвентаризация
            // ListTile(
            //   leading: const Icon(Icons.fact_check),
            //   title: const Text('Инвентаризация (inventory)'),
            //   onTap: () {
            //     Navigator.pop(ctx);
            //     _showSimpleCreateDialog('inventory');
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  /// Open “Приход” bottom sheet
  void _openProductReceivingSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ProductReceivingBloc()),
            BlocProvider(create: (_) => ProductSubCardBloc()..add(FetchProductSubCardsEvent())),
            BlocProvider(create: (_) => UnitBloc()..add(FetchUnitsEvent())),
            BlocProvider(create: (_) => ProviderBloc()..add(FetchProvidersEvent())),
            BlocProvider(create: (_) => ExpenseBloc()..add(FetchExpensesEvent())),
            BlocProvider(create: (_) => WarehouseBloc()..add(FetchWarehousesEvent())),
          ],
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.9,
            child: ProductReceivingPage(
              onClose: () {
                // The child will pop itself, we just refresh docs
                context.read<DocsBloc>().add(FetchDocsEvent());
              },
            ),
          ),
        );
      },
    );
  }

  /// Open “Списание” bottom sheet
  void _openWriteOffSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ProductWriteOffBloc()),
            BlocProvider(create: (_) => ProductSubCardBloc()..add(FetchProductSubCardsEvent())),
            BlocProvider(create: (_) => UnitBloc()..add(FetchUnitsEvent())),
            BlocProvider(create: (_) => ProviderBloc()..add(FetchProvidersEvent())),
            BlocProvider(create: (_) => ExpenseBloc()..add(FetchExpensesEvent())),
            BlocProvider(create: (_) => WarehouseBloc()..add(FetchWarehousesEvent())),
          ],
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.9,
            child: ProductWriteOffPage(
              onClose: () {
                // The child will pop itself, we just refresh
                context.read<DocsBloc>().add(FetchDocsEvent());
              },
            ),
          ),
        );
      },
    );
  }

  /// Open “Перемещение” bottom sheet
  void _openTransferSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            // Provide ProductTransferBloc (that you create similarly to ProductReceivingBloc)
            BlocProvider(create: (_) => ProductTransferBloc()),

            // Provide subcard, units, warehouses, etc. if needed
            BlocProvider(create: (_) => ProductSubCardBloc()..add(FetchProductSubCardsEvent())),
            BlocProvider(create: (_) => UnitBloc()..add(FetchUnitsEvent())),
            BlocProvider(create: (_) => WarehouseBloc()..add(FetchWarehousesEvent())),
            // If you need expenses or providers for some reason:
            // BlocProvider(create: (_) => ExpenseBloc()..add(FetchExpensesEvent())),
            // BlocProvider(create: (_) => ProviderBloc()..add(FetchProvidersEvent())),
          ],
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.9,
            child: ProductTransferPage(
              onClose: () {
                // The child will pop itself, we just refresh docs
                context.read<DocsBloc>().add(FetchDocsEvent());
              },
            ),
          ),
        );
      },
    );
  }

  void _showSimpleCreateDialog(String docType) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Создать документ: $docType'),
        content: Text('(Здесь можно сделать форму для "$docType")'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Possibly create doc, then refresh
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  /// Stub for editing a doc
  void _editDoc(DocItem doc) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _EditDocModal(doc: doc),
    );
  }

  /// Stub for deleting a doc
  void _deleteDoc(DocItem doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить документ?'),
        content: Text('Точно удалить документ #${doc.docId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      context.read<DocsBloc>().add(DeleteDocEvent(doc.docId));
    }
  }

  /// Helper to map doc type code -> label
  String _mapTypeLabel(String code) {
    switch (code) {
      case 'income':
        return 'Приход';
      case 'sale':
        return 'Продажа';
      case 'write_off':
        return 'Списание';
      case 'transfer':
        return 'Перемещение';
      case 'priceOffer':
        return 'Цен. предложение';
      case 'inventory':
        return 'Инвентаризация';
      default:
        return code;
    }
  }

  /// Helper to format doc date
  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}.${dt.month}.${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

/// Stub: bottom sheet for editing doc
class _EditDocModal extends StatelessWidget {
  final DocItem doc;
  const _EditDocModal({Key? key, required this.doc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: pagePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Редактирование документа #${doc.docId}', style: subheadingStyle),
          const SizedBox(height: 8),
          Text('Тип: ${doc.type}', style: bodyTextStyle),
          const SizedBox(height: 16),
          const Text('(Здесь поля для редактирования)', style: bodyTextStyle),
          const SizedBox(height: 16),
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть', style: buttonTextStyle),
          ),
        ],
      ),
    );
  }
}
