import 'package:alan/bloc/blocs/packer_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/warehouse_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/warehouse_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:alan/constant.dart'; // For consistent design

class PackagingScreen extends StatefulWidget {
  const PackagingScreen({super.key});

  @override
  State<PackagingScreen> createState() => _PackagingScreenState();
}

class _PackagingScreenState extends State<PackagingScreen> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PackagingBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Склад', style: headingStyle),
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
                child: BlocBuilder<PackagingBloc, PackagingState>(
  builder: (context, state) {
    if (state is PackagingLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PackagingLoaded) {
      if (state.tableData.isEmpty) {
        return const Center(child: Text('Нет данных', style: bodyTextStyle));
      }
      return SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => primaryColor.withOpacity(0.2),
          ),
          columns: const [
            DataColumn(
              label: Text('Наименование', style: tableHeaderStyle),
            ),
            DataColumn(
              label: Text('Ед изм', style: tableHeaderStyle),
            ),
            DataColumn(
              label: Text('Количество', style: tableHeaderStyle),
            ),
          ],
          rows: state.tableData
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(Text(item['name'], style: bodyTextStyle)),
                    DataCell(Text(item['unit'], style: bodyTextStyle)),
                    DataCell(Text(item['quantity'].toString(), style: bodyTextStyle)),
                  ],
                ),
              )
              .toList(),
        ),
      );
    } else if (state is PackagingError) {
      return Center(
        child: Text(
          state.error,
          style: bodyTextStyle.copyWith(color: Colors.red),
        ),
      );
    }
    return const Center(child: Text('Нет данных', style: bodyTextStyle));
  },
),
),
            ],
          ),
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
      context.read<PackagingBloc>().add(
            FetchPackagingDataEvent(
              startDate: startDate!,
              endDate: endDate!,
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
