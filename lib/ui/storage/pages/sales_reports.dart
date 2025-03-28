import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Подключаем ваш BLoC
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_report_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_report_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_report_state.dart';

// Модель (если нужна)
import 'package:alan/ui/admin/widgets/storage_report_item.dart';

// Стили и цвета из constant.dart
import 'package:alan/constant.dart';

class SalesReportPage extends StatelessWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Провайдим BLoC. Если уже провайдите выше — уберите BlocProvider отсюда.
    return BlocProvider(
      create: (_) => StorageReportBloc(),
      child: const StorageReportView(),
    );
  }
}

class StorageReportView extends StatefulWidget {
  const StorageReportView({Key? key}) : super(key: key);

  @override
  _StorageReportViewState createState() => _StorageReportViewState();
}

class _StorageReportViewState extends State<StorageReportView> {
  // Два поля для хранения выбранных дат
  DateTime? selectedDateFrom;
  DateTime? selectedDateTo;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StorageReportBloc>();

    return BlocBuilder<StorageReportBloc, StorageReportState>(
      builder: (context, state) {
        // Определяем, что показывать
        Widget content;
        if (state is StorageReportLoading) {
          content = const Center(child: CircularProgressIndicator());
        } else if (state is StorageReportError) {
          content = Center(
            child: Text(
              'Ошибка: ${state.message}',
              style: bodyTextStyle.copyWith(color: errorColor),
            ),
          );
        } else if (state is StorageReportLoaded) {
          // Если данные загружены, строим таблицу
          content = _buildDataTable(state.storageData);
        } else {
          // StorageReportInitial
          content = const Center(
            child: Text(
              'Нажмите "Сформировать", чтобы загрузить данные.',
              style: bodyTextStyle,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: const Text('Отчёт по складу', style: headingStyle),
          ),
          backgroundColor: backgroundColor,
          body: SingleChildScrollView(
            padding: pagePadding,
            child: Column(
              children: [
                // Фильтры (дата от/дата по + кнопка)
                Row(
                  children: [
                    // Поле «Дата от»
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: GestureDetector(
                          onTap: _pickDateFrom,
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedDateFrom != null
                                        ? DateFormat('yyyy-MM-dd').format(selectedDateFrom!)
                                        : 'Дата от',
                                    style: bodyTextStyle.copyWith(fontSize: 12),
                                  ),
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Поле «Дата по»
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: GestureDetector(
                          onTap: _pickDateTo,
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedDateTo != null
                                        ? DateFormat('yyyy-MM-dd').format(selectedDateTo!)
                                        : 'Дата по',
                                    style: bodyTextStyle.copyWith(fontSize: 12),
                                  ),
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Кнопка «Сформировать»
                    ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () {
                        final dateFromStr = selectedDateFrom != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDateFrom!)
                            : '';
                        final dateToStr = selectedDateTo != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDateTo!)
                            : '';

                        // Диспатчим событие для получения отчёта
                        bloc.add(
                          FetchStorageReportEvent(
                            dateFrom: dateFromStr,
                            dateTo: dateToStr,
                          ),
                        );
                      },
                      child: const Text('Сформировать', style: buttonTextStyle),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Содержимое (либо "нет данных", либо таблица)
                content,
              ],
            ),
          ),
        );
      },
    );
  }

  /// Выбор даты "от"
  Future<void> _pickDateFrom() async {
    final initial = selectedDateFrom ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDateFrom = picked;
      });
    }
  }

  /// Выбор даты "до"
  Future<void> _pickDateTo() async {
    final initial = selectedDateTo ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDateTo = picked;
      });
    }
  }

  /// Строим DataTable (без группировок)
  Widget _buildDataTable(List<StorageReportItem> reportData) {
    if (reportData.isEmpty) {
      return const Text('Нет данных', style: bodyTextStyle);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: MaterialStateProperty.all(primaryColor),
        columns: [
          DataColumn(
            label: Text('Склад', style: tableHeaderStyle),
          ),
          DataColumn(
            label: Text('Товар', style: tableHeaderStyle),
          ),
          DataColumn(
            label: Text('Приход', style: tableHeaderStyle),
          ),
          DataColumn(
            label: Text('Расход', style: tableHeaderStyle),
          ),
          DataColumn(
            label: Text('Остаток', style: tableHeaderStyle),
          ),
          DataColumn(
            label: Text('Себестоимость', style: tableHeaderStyle),
          ),
        ],
        rows: reportData.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.warehouseName, style: bodyTextStyle)),
              DataCell(Text(item.productName, style: bodyTextStyle)),
              DataCell(Text(item.totalInbound.toStringAsFixed(2), style: bodyTextStyle)),
              DataCell(Text(item.totalOutbound.toStringAsFixed(2), style: bodyTextStyle)),
              DataCell(Text(item.remainder.toStringAsFixed(2), style: bodyTextStyle)),
              DataCell(Text(item.currentCostPrice.toStringAsFixed(2), style: bodyTextStyle)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
