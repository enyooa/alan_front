import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoCs
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/warehouse_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/warehouse_state.dart';

// Styles
import 'package:alan/constant_new_version.dart';

/// Model to bundle up the chosen filter data for Transfer
class TransferFilterData {
  final int? sourceWhId;
  final int? destWhId;
  final DateTime? date;

  TransferFilterData({
    this.sourceWhId,
    this.destWhId,
    this.date,
  });
}

class FilterTransferPage extends StatefulWidget {
  final TransferFilterData initialFilter;

  const FilterTransferPage({Key? key, required this.initialFilter}) : super(key: key);

  @override
  State<FilterTransferPage> createState() => _FilterTransferPageState();
}

class _FilterTransferPageState extends State<FilterTransferPage> {
  int? _sourceWhId;
  int? _destWhId;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Pre-populate from the initial filter
    _sourceWhId   = widget.initialFilter.sourceWhId;
    _destWhId     = widget.initialFilter.destWhId;
    _selectedDate = widget.initialFilter.date;

    // Fetch warehouses
    context.read<WarehouseBloc>().add(FetchWarehousesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтр для Перемещения', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor], // #0ABCD7 -> #6CC6DA
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
              setState(() {
                _sourceWhId   = null;
                _destWhId     = null;
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
            _buildSourceWhDropdown(),
            const SizedBox(height: 16),
            _buildDestWhDropdown(),
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
              onPressed: _onApplyFilter,
              child: const Text('Показать', style: buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceWhDropdown() {
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
              child: Text(w['name'] ?? 'NoName', style: bodyTextStyle),
            );
          }).toList();

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:12, vertical:6),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _sourceWhId,
                  onChanged: (val) => setState(() => _sourceWhId = val),
                  hint: Text('Откуда', style: bodyTextStyle),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  items: items,
                ),
              ),
            ),
          );
        }
        return const Text('Загрузка складов...', style: bodyTextStyle);
      },
    );
  }

  Widget _buildDestWhDropdown() {
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
              child: Text(w['name'] ?? 'NoName', style: bodyTextStyle),
            );
          }).toList();

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:12, vertical:6),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _destWhId,
                  onChanged: (val) => setState(() => _destWhId = val),
                  hint: Text('Куда', style: bodyTextStyle),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  items: items,
                ),
              ),
            ),
          );
        }
        return const Text('Загрузка складов...', style: bodyTextStyle);
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
          padding: const EdgeInsets.symmetric(horizontal:12, vertical:10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate == null
                  ? 'Дата'
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                style: bodyTextStyle,
              ),
              const Icon(Icons.calendar_today, color: Colors.grey, size:16),
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

  void _onApplyFilter() {
    final filter = TransferFilterData(
      sourceWhId: _sourceWhId,
      destWhId:   _destWhId,
      date:       _selectedDate,
    );
    Navigator.pop(context, filter);
  }
}
