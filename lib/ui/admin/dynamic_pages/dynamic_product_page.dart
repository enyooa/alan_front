import 'package:alan/ui/admin/widgets/edit_receiving_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// BLoC for listing docs
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/docs_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/docs_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/docs_state.dart';

// BLoC for single doc editing (e.g. “income” doc)
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';

// Models
import 'package:alan/bloc/models/doc_item.dart';

// "Create" pages or bottom sheets
import 'package:alan/ui/admin/dynamic_pages/product_options/product_receiving_page.dart';
import 'package:alan/ui/admin/dynamic_pages/product_options/write_off_widget.dart';
import 'package:alan/ui/admin/dynamic_pages/product_options/transfer_widget.dart';

// "Edit" dialog (for “income” doc)

// Constants / styles
import 'package:alan/constant.dart';

class DynamicProductPage extends StatelessWidget {
  const DynamicProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide DocsBloc so we can fetch & display all documents
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
  // Filter fields
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

  // ============================
  //  PART 1) FILTERS
  // ============================
  Widget _buildFilters() {
    final docTypeOptions = [
      {'label': 'Все типы', 'value': null, 'icon': FontAwesomeIcons.boxesPacking},
      {'label': 'Приход', 'value': 'income', 'icon': FontAwesomeIcons.arrowDown},
      {'label': 'Списание', 'value': 'write_off', 'icon': FontAwesomeIcons.trash},
      {'label': 'Перемещение', 'value': 'transfer', 'icon': FontAwesomeIcons.truckFast},
    ];

    return Row(
      children: [
        // Dropdown for doc type
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String?>(
            value: selectedDocType,
            items: docTypeOptions.map((opt) {
              return DropdownMenuItem<String?>(
                value: opt['value'] as String?,
                child: Row(
                  children: [
                    FaIcon(opt['icon'] as IconData, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(opt['label'] as String, style: bodyTextStyle),
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

        // Search textfield
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

  // ============================
  //  PART 2) DOCS LIST
  // ============================
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
      final providerStr = (doc.providerName ?? '').toLowerCase();
      final dateStr = doc.documentDate.toLowerCase();

      return docIdStr.contains(lowerQ)
          || docNumStr.contains(lowerQ)
          || providerStr.contains(lowerQ)
          || dateStr.contains(lowerQ);
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
            DataCell(Text(doc.documentDate, style: bodyTextStyle)),
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

  // ============================
  //  PART 3) FAB => CREATE DOC
  // ============================
  void _onFabPressed() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Приход'),
              onTap: () {
                Navigator.pop(ctx);
                _openProductReceivingSheet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Списание'),
              onTap: () {
                Navigator.pop(ctx);
                // ...
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync_alt),
              title: const Text('Перемещение'),
              onTap: () {
                Navigator.pop(ctx);
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show a bottom sheet for creating an "income" doc
  void _openProductReceivingSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        // Example: show a "create income" widget
        return SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.9,
          child: ProductReceivingPage(
            onClose: () {
              Navigator.pop(ctx);
              // Refresh after creation
              context.read<DocsBloc>().add(FetchDocsEvent());
            },
          ),
        );
      },
    );
  }

  // ============================
  //  PART 4) EDIT DOC
  // ============================
  void _editDoc(DocItem doc) async {
    if (doc.type == 'income') {
      // Show an EditReceiptDialog for "Приход" doc
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          // Instead of creating a StorageReceivingBloc, we now use ProductReceivingBloc
          return BlocProvider(
            create: (_) => ProductReceivingBloc(),
            child: EditReceiptDialog(docId: doc.docId),
          );
        },
      );
      // After the dialog closes, refresh
      context.read<DocsBloc>().add(FetchDocsEvent());
    } else {
      // e.g. write_off / transfer => similar approach
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No edit dialog for doc type: ${doc.type}')),
      );
    }
  }

  // ============================
  //  PART 5) DELETE DOC
  // ============================
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
            child: const Text('Удалить', style: TextStyle(color: errorColor)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // If your DocsBloc handles deletion:
      context.read<DocsBloc>().add(DeleteDocEvent(doc.docId));
      // Or do your direct API call & refresh
    }
  }

  // ============================
  //  PART 6) HELPERS
  // ============================
  String _mapTypeLabel(String code) {
    switch (code) {
      case 'income':
        return 'Приход';
      case 'write_off':
        return 'Списание';
      case 'transfer':
        return 'Перемещение';
      default:
        return code;
    }
  }
}
