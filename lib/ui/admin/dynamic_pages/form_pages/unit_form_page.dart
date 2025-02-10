import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alan/constant.dart';

class UnitFormPage extends StatefulWidget {
  @override
  _UnitFormPageState createState() => _UnitFormPageState();
}
class _UnitFormPageState extends State<UnitFormPage> {
  final TextEditingController unitNameController = TextEditingController();
  final TextEditingController tareController = TextEditingController(); // Add controller for tare

  @override
  void dispose() {
    unitNameController.dispose();
    tareController.dispose(); // Dispose tare controller
    super.dispose();
  }

  void _saveUnit(BuildContext context) {
    final unitName = unitNameController.text.trim();
    final tare = tareController.text.trim();

    if (unitName.isEmpty || tare.isEmpty) {  // Check both fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Пожалуйста, введите наименование единицы и тару',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<UnitBloc>().add(CreateUnitEvent(name: unitName, tare: tare)); // Pass tare value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать Единицу Измерения', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocConsumer<UnitBloc, UnitState>(
        listener: (context, state) {
          if (state is UnitFetchedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Единица успешно сохранена',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
            unitNameController.clear();
            tareController.clear(); // Clear tare controller
          } else if (state is UnitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UnitLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(unitNameController, 'Наименование единицы'),
                const SizedBox(height: 10),
                _buildTextField(tareController, 'Тара (Вес упаковки)'), // Add tare input field
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _saveUnit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Сохранить',
                    style: buttonTextStyle,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: subheadingStyle,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      style: bodyTextStyle,
    );
  }
}
