import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoCs
import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/provider_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/provider_state.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/warehouse_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/warehouse_state.dart';

// Same constants as in your main page (colors, styles, etc.)
import 'package:alan/constant_new_version.dart';

/// This model just bundles up the chosen filter data.
class ProductReceivingFilterData {
  final int? providerId;
  final int? warehouseId;
  final DateTime? selectedDate;

  ProductReceivingFilterData({
    this.providerId,
    this.warehouseId,
    this.selectedDate,
  });
}

class FilterProductReceivingPage extends StatefulWidget {
  /// If you’d like, you can pass in an existing filter to pre-populate
  final ProductReceivingFilterData initialFilter;

  const FilterProductReceivingPage({
    Key? key,
    required this.initialFilter,
  }) : super(key: key);

  @override
  State<FilterProductReceivingPage> createState() => _FilterProductReceivingPageState();
}

class _FilterProductReceivingPageState extends State<FilterProductReceivingPage> {
  int? _selectedProviderId;
  int? _selectedWarehouseId;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Pre-populate from initial filter
    _selectedProviderId  = widget.initialFilter.providerId;
    _selectedWarehouseId = widget.initialFilter.warehouseId;
    _selectedDate        = widget.initialFilter.selectedDate;

    // Trigger BLoCs if needed
    context.read<ProviderBloc>().add(FetchProvidersEvent());
    context.read<WarehouseBloc>().add(FetchWarehousesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use the same gradient or color scheme as your main page
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Фильтр',
          style: TextStyle(color: Colors.white),
        ),
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
              // “Сбросить” => reset local state
              setState(() {
                _selectedProviderId  = null;
                _selectedWarehouseId = null;
                _selectedDate        = null;
              });
            },
            child: const Text(
              'Сбросить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProviderDropdown(),
            const SizedBox(height: 16),
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
                // “Показать” => pop back with chosen filter data
                Navigator.pop<ProductReceivingFilterData>(
                  context,
                  ProductReceivingFilterData(
                    providerId:  _selectedProviderId,
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

  Widget _buildProviderDropdown() {
    return BlocBuilder<ProviderBloc, ProviderState>(
      builder: (context, state) {
        if (state is ProviderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProvidersLoaded) {
          final items = state.providers.map<DropdownMenuItem<int>>((p) {
            return DropdownMenuItem<int>(
              value: p.id,
              child: Text(p.name, style: bodyTextStyle.copyWith(fontSize: 14)),
            );
          }).toList();

          return _buildStyledDropdown<int>(
            label: 'Поставщик',
            value: _selectedProviderId,
            items: items,
            onChanged: (val) => setState(() => _selectedProviderId = val),
          );
        }
        return const Text('Ошибка загрузки поставщиков', style: bodyTextStyle);
      },
    );
  }

  Widget _buildWarehouseDropdown() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, whState) {
        if (whState is WarehouseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (whState is WarehouseError) {
          return Text('Ошибка складов: ${whState.message}', style: bodyTextStyle);
        } else if (whState is WarehouseLoaded) {
          final items = whState.warehouses.map<DropdownMenuItem<int>>((w) {
            return DropdownMenuItem<int>(
              value: w['id'],
              child: Text(
                w['name'] ?? 'NoName',
                style: bodyTextStyle.copyWith(fontSize: 14),
              ),
            );
          }).toList();

          return _buildStyledDropdown<int>(
            label: 'Склад',
            value: _selectedWarehouseId,
            items: items,
            onChanged: (val) => setState(() => _selectedWarehouseId = val),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate == null
                    ? 'Дата'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                style: bodyTextStyle.copyWith(fontSize: 14),
              ),
              const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
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

  // Reusable styled dropdown
  Widget _buildStyledDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            items: items,
            onChanged: onChanged,
            hint: Text(label, style: bodyTextStyle.copyWith(fontSize: 14)),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
