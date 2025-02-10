import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_report_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_report_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/constant.dart';

class StorageReportPage extends StatefulWidget {
  @override
  _StorageReportPageState createState() => _StorageReportPageState();
}

class _StorageReportPageState extends State<StorageReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<StorageReportBloc>().add(FetchStorageReportEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчет по складу', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocBuilder<StorageReportBloc, StorageReportState>(
        builder: (context, state) {
          if (state is StorageReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StorageReportError) {
            return Center(
              child: Text('Ошибка: ${state.message}', style: bodyTextStyle),
            );
          }
          if (state is StorageReportLoaded) {
            final storageData = state.storageData;
            return _buildTable(storageData);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> storageData) {
    if (storageData.isEmpty) {
      return const Center(child: Text('Нет данных для отображения.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(primaryColor),
        border: TableBorder.all(color: borderColor),
        columns: const [
          DataColumn(label: Text('Наименование')),
          DataColumn(label: Text('Ед изм')),
          DataColumn(label: Text('Приход')),
          DataColumn(label: Text('Расход')),
          DataColumn(label: Text('Остаток')),
        ],
        rows: storageData.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item['product'] ?? '')),
              DataCell(Text(item['unit'] ?? '')),
              DataCell(Text(item['incoming'].toString())),
              DataCell(Text(item['outgoing'].toString())),
              DataCell(Text(item['remaining'].toString())),
            ],
          );
        }).toList(),
      ),
    );
  }
}
