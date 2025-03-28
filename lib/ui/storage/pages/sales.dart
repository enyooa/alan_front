import 'package:alan/bloc/blocs/storage_page_blocs/blocs/sales_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/sales_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/sales_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


// BLoC imports for references
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_references_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_references_state.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_references_event.dart';

// Your constants + styles
import 'package:alan/constant.dart';

// The SaleWidget using real references
import 'package:alan/ui/storage/widgets/sale_widget.dart';

class StoragerSalePage extends StatefulWidget {
  const StoragerSalePage({Key? key}) : super(key: key);

  @override
  State<StoragerSalePage> createState() => _StoragerSalePageState();
}

class _StoragerSalePageState extends State<StoragerSalePage> {
  @override
  void initState() {
    super.initState();
    // 1) Fetch references for clients, units, productSubCards, etc.
    context.read<StorageReferencesBloc>().add(FetchAllInstancesEvent());

    // 2) Fetch existing sales
    context.read<StorageSalesBloc>().add(FetchAllSalesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Продажи", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: BlocConsumer<StorageSalesBloc, StorageSalesState>(
        listener: (context, state) {
          if (state is StorageSalesCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Refetch updated list
            context.read<StorageSalesBloc>().add(FetchAllSalesEvent());
          } else if (state is StorageSalesUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<StorageSalesBloc>().add(FetchAllSalesEvent());
          } else if (state is StorageSalesDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<StorageSalesBloc>().add(FetchAllSalesEvent());
          } else if (state is StorageSalesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is StorageSalesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StorageSalesListLoaded) {
            final sales = state.sales;
            return _buildSalesTable(sales);
          } else if (state is StorageSalesError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          } else {
            return const Center(
              child: Text('Нет сохранённых продаж. Нажмите + чтобы добавить.'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _openSaleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSalesTable(List<dynamic> sales) {
    if (sales.isEmpty) {
      return const Center(
        child: Text('Нет сохранённых продаж. Нажмите + чтобы добавить.'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(primaryColor),
        columns: [
          DataColumn(label: Text('ID', style: tableHeaderStyle)),
          DataColumn(label: Text('Client', style: tableHeaderStyle)),
          DataColumn(label: Text('Date', style: tableHeaderStyle)),
          DataColumn(label: Text('Edit', style: tableHeaderStyle)),
          DataColumn(label: Text('Delete', style: tableHeaderStyle)),
        ],
        rows: sales.map<DataRow>((sale) {
          final id = sale['id']?.toString() ?? '-';
          final clientName = sale['client']?['name'] ??
              (sale['client']?['first_name'] ?? 'NoClient');
          final date = sale['document_date'] ?? '-';

          return DataRow(cells: [
            DataCell(Text(id, style: tableCellStyle)),
            DataCell(Text(clientName, style: tableCellStyle)),
            DataCell(Text(date, style: tableCellStyle)),
            DataCell(
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () => _onEdit(sale),
              ),
            ),
            DataCell(
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _onDelete(sale),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  // Called when user taps Edit
  void _onEdit(dynamic sale) async {
    final docId = sale['id'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit sale #$docId (placeholder)')),
    );
  }

  // Called when user taps Delete
  void _onDelete(dynamic sale) {
    final docId = sale['id'] as int?;
    if (docId == null) return;
    context.read<StorageSalesBloc>().add(DeleteSaleEvent(docId: docId));
  }

  // Opening the "SaleWidget" in a dialog, with *real* references
  Future<void> _openSaleDialog() async {
    // 1) Check if references are loaded
    final refState = context.read<StorageReferencesBloc>().state;
    if (refState is! StorageReferencesLoaded) {
      // Not loaded or error, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Справочники не загружены. Подождите...')),
      );
      return;
    }

    // 2) We have references
    final clients = refState.clients;              // dynamic list
    final productSubCards = refState.productSubCards;
    final unitMeasurements = refState.unitMeasurements;
    // (If you have "expenses" for sale, you'd also get refState.expenses, etc.)

    // 3) Show dialog with SaleWidget
    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: SaleWidget(
          clients: clients,
          productSubCards: productSubCards,
          unitMeasurements: unitMeasurements,
        ),
      ),
    );

    if (result != null) {
      // 4) The widget calls pop(payload)
      final newSaleMap = result as Map<String, dynamic>;
      // If your backend expects a list, pass it as [newSaleMap]
      context.read<StorageSalesBloc>().add(
        CreateSalesEvent(sales: [newSaleMap]),
      );
    }
  }
}
