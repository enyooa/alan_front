import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/constant.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_report_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_report_state.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<StorageReportBloc>().add(FetchStorageReportEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчет по продажам', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocBuilder<StorageReportBloc, StorageReportState>(
        builder: (context, state) {
          if (state is StorageReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StorageReportError) {
            return Center(
              child: Text(state.message, style: bodyTextStyle),
            );
          }
          if (state is StorageReportLoaded) {
            return _buildTable(state.storageData);
          }
          return const Center(
            child: Text('Нет данных для отображения.', style: bodyTextStyle),
          );
        },
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> salesData) {
    if (salesData.isEmpty) {
      return const Center(child: Text('Нет данных для отображения.', style: tableHeaderStyle));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(primaryColor),
          dataRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          border: TableBorder.all(color: borderColor),
          headingTextStyle: tableHeaderStyle,
          dataTextStyle: tableCellStyle,
          columns: const [
            DataColumn(label: Text('Наименование', style: tableHeaderStyle)),
            DataColumn(label: Text('Ед Изм', style: tableHeaderStyle)),
            DataColumn(label: Text('Количество', style: tableHeaderStyle)),
            DataColumn(label: Text('Цена', style: tableHeaderStyle)),
            DataColumn(label: Text('Сумма', style: tableHeaderStyle)),
            DataColumn(label: Text('Остаток', style: tableHeaderStyle)),
          ],
          rows: salesData.map((sale) {
            return DataRow(
              cells: [
                DataCell(Text(sale['product'] ?? '', style: tableCellStyle)),
                DataCell(Text(sale['unit'] ?? '', style: tableCellStyle)),
                DataCell(Text(sale['quantity'].toString(), style: tableCellStyle)),
                DataCell(Text(sale['price'].toString(), style: tableCellStyle)),
                DataCell(Text(sale['total'].toString(), style: tableCellStyle)),
                DataCell(Text((sale['remaining'] ?? 0).toString(), style: tableCellStyle)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
