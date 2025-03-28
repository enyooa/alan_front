// edit_unit_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:alan/constant.dart';

class EditUnitPage extends StatefulWidget {
  final int unitId; // The ID to fetch & edit

  const EditUnitPage({
    Key? key,
    required this.unitId,
  }) : super(key: key);

  @override
  _EditUnitPageState createState() => _EditUnitPageState();
}

class _EditUnitPageState extends State<EditUnitPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tareController = TextEditingController();

  bool _didLoadData = false; // so we only set fields once

  @override
  void initState() {
    super.initState();
    // 1) Dispatch a single fetch for the unit
    context.read<UnitBloc>().add(
      FetchSingleUnitEvent(id: widget.unitId),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    tareController.dispose();
    super.dispose();
  }

  void _save() {
    final name = nameController.text.trim();
    final tareString = tareController.text.trim().replaceAll(',', '.');
    final tareDouble = double.tryParse(tareString);

    final data = <String, dynamic>{
      'name': name,
      // If user typed a valid number, set it; else you could set null
      'tare': tareDouble ?? null,
    };

    // 2) Dispatch update
    context.read<UnitBloc>().add(
      UpdateUnitEvent(id: widget.unitId, data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UnitBloc, UnitState>(
      listener: (context, state) {
        if (state is UnitUpdatedSuccess) {
          // success => show toast & close
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context, true);
        } else if (state is UnitError) {
          // show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: BlocBuilder<UnitBloc, UnitState>(
        builder: (context, state) {
          final isLoading = state is UnitLoading;

          // 3) Once we fetch single data, fill fields if not done yet
          if (state is SingleUnitLoaded && !_didLoadData) {
            final unit = state.unitData;
            nameController.text = unit['name'] ?? '';
            tareController.text = (unit['tare'] != null)
                ? unit['tare'].toString()
                : '';
            _didLoadData = true;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Редактировать единицу измерения', style: headingStyle),
              backgroundColor: primaryColor,
            ),
            body: SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Название единицы', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Тара (в граммах)', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tareController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Сохранить', style: buttonTextStyle),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
