import 'package:cash_control/bloc/blocs/packer_page_blocs/events/packer_requests_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/states/packer_requests_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/constant.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/blocs/packer_requests_bloc.dart';


class RequestsScreen extends StatefulWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<Map<String, dynamic>> tableRows = [
    {
      'name': null,
      'unit': null,
      'quantity': 0.0,
      'price': 0.0,
      'total': 0.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RequestsBloc(baseUrl: baseUrl),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Накладная',
            style: headingStyle,
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          elevation: 4,
        ),
        body: BlocListener<RequestsBloc, RequestsState>(
          listener: (context, state) {
            if (state is RequestsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is RequestsSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Данные успешно сохранены!')),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildEditableTable(),
                const SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the editable table
  Widget _buildEditableTable() {
    return Table(
      border: TableBorder.all(color: borderColor),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(0.5),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: primaryColor),
          children: const [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Наименование', style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Ед изм', style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Кол-во', style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Цена', style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Сумма', style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Удалить', style: tableHeaderStyle, textAlign: TextAlign.center),
            ),
          ],
        ),
        ...tableRows.asMap().entries.map(
          (entry) {
            int index = entry.key;
            Map<String, dynamic> row = entry.value;
            return TableRow(
              decoration: BoxDecoration(
                color: index % 2 == 0 ? backgroundColor : Colors.white,
              ),
              children: [
                TextField(
                  onChanged: (value) => setState(() => row['name'] = value),
                  decoration: const InputDecoration(hintText: 'Введите название'),
                ),
                DropdownButtonFormField<String>(
                  value: row['unit'],
                  items: ['шт', 'кг', 'л'].map((unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: (value) => setState(() => row['unit'] = value),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      row['quantity'] = double.tryParse(value) ?? 0.0;
                      row['total'] = row['quantity'] * row['price'];
                    });
                  },
                  decoration: const InputDecoration(hintText: 'Кол-во'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      row['price'] = double.tryParse(value) ?? 0.0;
                      row['total'] = row['quantity'] * row['price'];
                    });
                  },
                  decoration: const InputDecoration(hintText: 'Цена'),
                  keyboardType: TextInputType.number,
                ),
                Center(
                  child: Text(row['total'].toStringAsFixed(2)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => tableRows.removeAt(index)),
                ),
              ],
            );
          },
        ).toList(),
      ],
    );
  }

  /// Build the header fields for client name and delivery address
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Наименование клиента:', style: subheadingStyle),
        SizedBox(height: 8),
        Text('Адрес доставки:', style: subheadingStyle),
      ],
    );
  }

  /// Build action buttons for saving and printing
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          onPressed: () => _saveRequests(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: buttonPadding,
          ),
          icon: const Icon(Icons.receipt_long, color: Colors.white),
          label: const Text('Создать накладную', style: buttonTextStyle),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Implement print functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: buttonPadding,
          ),
          icon: const Icon(Icons.print, color: Colors.white),
          label: const Text('Печать', style: buttonTextStyle),
        ),
      ],
    );
  }

  /// Save requests using the bloc
  void _saveRequests(BuildContext context) {
    if (tableRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    context.read<RequestsBloc>().add(SaveRequestsEvent(requests: tableRows));
  }
}
