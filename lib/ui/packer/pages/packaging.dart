import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:alan/constant.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/warehouse_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/warehouse_state.dart';

class PackagingScreen extends StatefulWidget {
  const PackagingScreen({Key? key}) : super(key: key);

  @override
  State<PackagingScreen> createState() => _PackagingScreenState();
}

class _PackagingScreenState extends State<PackagingScreen> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    // There's NO BlocProvider here, we just access the existing one.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Движение товаров (Пэкер)', style: headingStyle),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Filter
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: startDate == null
                        ? "Дата с"
                        : DateFormat('yyyy-MM-dd').format(startDate!),
                    onDateSelected: (date) => setState(() => startDate = date),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDatePicker(
                    label: endDate == null
                        ? "Дата по"
                        : DateFormat('yyyy-MM-dd').format(endDate!),
                    onDateSelected: (date) => setState(() => endDate = date),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _filterData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text("Сформировать", style: buttonTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: BlocBuilder<WarehouseMovementBloc, WarehouseMovementState>(
                builder: (context, state) {
                  if (state is WarehouseMovementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is WarehouseMovementLoaded) {
                    final tableData = state.reportData;
                    if (tableData.isEmpty) {
                      return const Center(
                        child: Text('Нет данных', style: bodyTextStyle),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) => primaryColor.withOpacity(0.2),
                        ),
                        columns: const [
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
                            label: Text('Сумма остатка', style: tableHeaderStyle),
                          ),
                        ],
                        rows: tableData.map((row) {
                          final warehouseName = row['warehouse_name'] ?? '';
                          final productName   = row['product_name'] ?? '';
                          final inbound      = row['total_inbound'] ?? 0;
                          final outbound     = row['total_outbound'] ?? 0;
                          final remainder    = row['remainder'] ?? 0;
                          final remainderVal = row['remainder_value'] ?? 0;

                          return DataRow(
                            cells: [
                              DataCell(Text(warehouseName.toString(), style: bodyTextStyle)),
                              DataCell(Text(productName.toString(), style: bodyTextStyle)),
                              DataCell(Text(inbound.toString(), style: bodyTextStyle)),
                              DataCell(Text(outbound.toString(), style: bodyTextStyle)),
                              DataCell(Text(remainder.toString(), style: bodyTextStyle)),
                              DataCell(Text(remainderVal.toString(), style: bodyTextStyle)),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  } else if (state is WarehouseMovementError) {
                    return Center(
                      child: Text(
                        state.error,
                        style: bodyTextStyle.copyWith(color: Colors.red),
                      ),
                    );
                  }
                  return const Center(
                    child: Text('Нет данных', style: bodyTextStyle),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: bodyTextStyle),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _filterData() {
    if (startDate != null && endDate != null) {
      context.read<WarehouseMovementBloc>().add(
        FetchWarehouseMovementEvent(
          dateFrom: DateFormat('yyyy-MM-dd').format(startDate!),
          dateTo: DateFormat('yyyy-MM-dd').format(endDate!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите начальную и конечную дату'),
        ),
      );
    }
  }
}
