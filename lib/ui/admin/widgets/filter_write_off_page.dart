import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoCs
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/warehouse_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/warehouse_event.dart';

import 'package:alan/constant_new_version.dart';

/// Model to bundle up chosen filter data
class WriteOffFilterData {
  final int? warehouseId;
  final DateTime? selectedDate;

  WriteOffFilterData({
    this.warehouseId,
    this.selectedDate,
  });
}

class FilterProductWriteOffPage extends StatefulWidget {
  final WriteOffFilterData initialFilter;

  const FilterProductWriteOffPage({
    Key? key,
    required this.initialFilter,
  }) : super(key: key);

  @override
  State<FilterProductWriteOffPage> createState() => _FilterProductWriteOffPageState();
}

class _FilterProductWriteOffPageState extends State<FilterProductWriteOffPage> {
  int? _selectedWarehouseId;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedWarehouseId = widget.initialFilter.warehouseId;
    _selectedDate        = widget.initialFilter.selectedDate;

    context.read<WarehouseBloc>().add(FetchWarehousesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text('Фильтр Списания', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reset
              setState(() {
                _selectedWarehouseId = null;
                _selectedDate = null;
              });
            },
            child: const Text('Сбросить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWarehouseDropdown(),
            const SizedBox(height: 16),
            _buildDatePickerCard(),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                // Return chosen data to the calling page
                Navigator.pop<WriteOffFilterData>(
                  context,
                  WriteOffFilterData(
                    warehouseId: _selectedWarehouseId,
                    selectedDate: _selectedDate,
                  ),
                );
              },
              child: const Text('Показать', style: buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseDropdown() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, state) {
        if (state is WarehouseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WarehouseError) {
          return Text('Ошибка складов: ${state.message}', style: bodyTextStyle);
        } else if (state is WarehouseLoaded) {
          final items = state.warehouses.map<DropdownMenuItem<int>>((w) {
            return DropdownMenuItem<int>(
              value: w['id'],
              child: Text(
                w['name'] ?? 'NoName',
                style: bodyTextStyle.copyWith(fontSize: 14),
              ),
            );
          }).toList();

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedWarehouseId,
                  onChanged: (val) => setState(() => _selectedWarehouseId = val),
                  hint: Text('Склад', style: bodyTextStyle.copyWith(fontSize: 14)),
                  items: items,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildDatePickerCard() {
    return GestureDetector(
      onTap: _pickDate,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate == null
                    ? 'Дата'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                style: bodyTextStyle.copyWith(fontSize: 14),
              ),
              const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }
}
