import 'package:alan/bloc/blocs/storage_page_blocs/blocs/sales_report_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/sales_report_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/sales_report_state.dart';
import 'package:alan/bloc/models/sale_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// модель
import 'package:alan/constant.dart'; // стили, цвета

class SalesReportPage extends StatelessWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Подключаем BLoC
    return BlocProvider(
      create: (_) => SalesReportBloc(),
      child: const SalesReportView(),
    );
  }
}

class SalesReportView extends StatefulWidget {
  const SalesReportView({Key? key}) : super(key: key);

  @override
  _SalesReportViewState createState() => _SalesReportViewState();
}

class _SalesReportViewState extends State<SalesReportView> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SalesReportBloc>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Отчет по продажам', style: headingStyle),
      ),
      backgroundColor: backgroundColor,
      body: BlocBuilder<SalesReportBloc, SalesReportState>(
        builder: (context, state) {
          Widget content;

          if (state is SalesReportLoading) {
            content = const Center(child: CircularProgressIndicator());
          } else if (state is SalesReportError) {
            content = Center(
              child: Text(
                'Ошибка: ${state.message}',
                style: bodyTextStyle.copyWith(color: errorColor),
              ),
            );
          } else if (state is SalesReportLoaded) {
            content = _buildTable(state.salesData);
          } else {
            content = const Center(
              child: Text(
                'Нажмите «Сформировать» чтобы загрузить данные.',
                style: bodyTextStyle,
              ),
            );
          }

          return SingleChildScrollView(
            padding: pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilters(bloc),
                const SizedBox(height: 20),
                content,
              ],
            ),
          );
        },
      ),
    );
  }

  /// Фильтры (дата с / по + кнопки)
  Widget _buildFilters(SalesReportBloc bloc) {
    return Row(
      children: [
        // Дата с
        Expanded(
          child: GestureDetector(
            onTap: () => _pickStartDate(),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (startDate != null) 
                        ? DateFormat('yyyy-MM-dd').format(startDate!)
                        : 'Период c',
                      style: bodyTextStyle.copyWith(fontSize: 12),
                    ),
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Дата по
        Expanded(
          child: GestureDetector(
            onTap: () => _pickEndDate(),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (endDate != null) 
                        ? DateFormat('yyyy-MM-dd').format(endDate!)
                        : 'Период по',
                      style: bodyTextStyle.copyWith(fontSize: 12),
                    ),
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Кнопка "Сформировать"
        ElevatedButton(
          style: elevatedButtonStyle,
          onPressed: () {
            final startStr = (startDate != null)
                ? DateFormat('yyyy-MM-dd').format(startDate!)
                : '';
            final endStr = (endDate != null)
                ? DateFormat('yyyy-MM-dd').format(endDate!)
                : '';

            bloc.add(
              FetchSalesReportEvent(
                startDate: startStr,
                endDate: endStr,
              ),
            );
          },
          child: const Text('Сформировать', style: buttonTextStyle),
        ),

        const SizedBox(width: 8),

        // Кнопка «Экспорт в PDF»
        ElevatedButton(
          style: elevatedButtonStyle,
          onPressed: () {
            final startStr = (startDate != null)
                ? DateFormat('yyyy-MM-dd').format(startDate!)
                : '';
            final endStr = (endDate != null)
                ? DateFormat('yyyy-MM-dd').format(endDate!)
                : '';
            
            // Способ 1: диспатч события
            // bloc.add(ExportSalesPdfEvent(startDate: startStr, endDate: endStr));

            // Способ 2: открываем ссылку
            final query = [];
            if (startStr.isNotEmpty) query.add('start_date=$startStr');
            if (endStr.isNotEmpty) query.add('end_date=$endStr');
            final q = query.isNotEmpty ? '?${query.join('&')}' : '';
            final url = '${baseUrl}sales-report/pdf$q';
            print('Open PDF: $url');
            // Если Flutter Web, можно использовать html.window.open(url, '_blank');
            // Или пакет url_launcher для мобильного
          },
          child: const Text('Выгрузить PDF', style: buttonTextStyle),
        ),

        const SizedBox(width: 8),

        // Кнопка «Экспорт в Excel»
        ElevatedButton(
          style: elevatedButtonStyle,
          onPressed: () {
            final startStr = (startDate != null)
                ? DateFormat('yyyy-MM-dd').format(startDate!)
                : '';
            final endStr = (endDate != null)
                ? DateFormat('yyyy-MM-dd').format(endDate!)
                : '';
            
            final query = [];
            if (startStr.isNotEmpty) query.add('start_date=$startStr');
            if (endStr.isNotEmpty) query.add('end_date=$endStr');
            final q = query.isNotEmpty ? '?${query.join('&')}' : '';
            final url = '${baseUrl}sales-report/excel$q';
            print('Open Excel: $url');
            // Аналогично выше
          },
          child: const Text('Выгрузить Excel', style: buttonTextStyle),
        ),
      ],
    );
  }

  Future<void> _pickStartDate() async {
    final init = startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final init = endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  /// Строим таблицу данных
  Widget _buildTable(List<SalesRow> salesData) {
    if (salesData.isEmpty) {
      return const Text('Нет данных за выбранный период.', style: bodyTextStyle);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(primaryColor),
        columns: [
          DataColumn(label: Text('Товар', style: tableHeaderStyle)),
          DataColumn(label: Text('Количество', style: tableHeaderStyle)),
          DataColumn(label: Text('Сумма продаж', style: tableHeaderStyle)),
          DataColumn(label: Text('Себестоимость', style: tableHeaderStyle)),
          DataColumn(label: Text('Прибыль', style: tableHeaderStyle)),
          DataColumn(label: Text('Дата документа', style: tableHeaderStyle)),
        ],
        rows: salesData.map((row) {
          final isNegativeProfit = row.profit < 0;
          return DataRow(cells: [
            DataCell(Text(row.productName, style: bodyTextStyle)),
            DataCell(Text(row.quantity.toStringAsFixed(2), style: bodyTextStyle)),
            DataCell(Text(row.saleAmount.toStringAsFixed(2), style: bodyTextStyle)),
            DataCell(Text(row.costAmount.toStringAsFixed(2), style: bodyTextStyle)),
            DataCell(Text(
              row.profit.toStringAsFixed(2),
              style: bodyTextStyle.copyWith(
                color: isNegativeProfit ? Colors.red : Colors.black,
                fontWeight: isNegativeProfit ? FontWeight.bold : FontWeight.normal,
              ),
            )),
            DataCell(Text(row.documentDate, style: bodyTextStyle)),
          ]);
        }).toList(),
      ),
    );
  }
}
