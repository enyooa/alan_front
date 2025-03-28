import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:alan/constant.dart';

class EditSubCardPage extends StatefulWidget {
  final int subCardId;

  const EditSubCardPage({
    Key? key,
    required this.subCardId,
  }) : super(key: key);

  @override
  _EditSubCardPageState createState() => _EditSubCardPageState();
}

class _EditSubCardPageState extends State<EditSubCardPage> {
  final productCardIdController = TextEditingController();
  final nameController = TextEditingController();
  final bruttoController = TextEditingController();
  final nettoController = TextEditingController();

  bool _didLoadData = false; // so we only set fields once

  @override
  void initState() {
    super.initState();
    // 1) Dispatch fetch for the real subcard data
    context.read<ProductSubCardBloc>().add(
      FetchSingleSubCardEvent(widget.subCardId),
    );
  }

  @override
  void dispose() {
    productCardIdController.dispose();
    nameController.dispose();
    bruttoController.dispose();
    nettoController.dispose();
    super.dispose();
  }

  void _save() {
    final productCardId = int.tryParse(productCardIdController.text);
    final brutto = double.tryParse(bruttoController.text);
    final netto = double.tryParse(nettoController.text);

    final updatedFields = <String, dynamic>{
      'product_card_id': productCardId ?? 0,
      'name': nameController.text,
    };
    if (brutto != null) updatedFields['brutto'] = brutto;
    if (netto != null) updatedFields['netto'] = netto;

    context.read<ProductSubCardBloc>().add(
      UpdateProductSubCardEvent(
        id: widget.subCardId,
        updatedFields: updatedFields,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductSubCardBloc, ProductSubCardState>(
      listener: (context, state) {
        if (state is ProductSubCardUpdated) {
          // success => close
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context, true);
        } else if (state is ProductSubCardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
        builder: (context, state) {
          final isLoading = state is ProductSubCardLoading;

          // 2) Once we have the single subcard data, fill fields if not done yet
          if (state is SingleProductSubCardLoaded && !_didLoadData) {
            final sub = state.subCard;
            productCardIdController.text = sub['product_card_id']?.toString() ?? '';
            nameController.text = sub['name'] ?? '';
            bruttoController.text = sub['brutto']?.toString() ?? '';
            nettoController.text = sub['netto']?.toString() ?? '';
            _didLoadData = true;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Редактировать подкарточку', style: headingStyle),
              backgroundColor: primaryColor,
            ),
            body: SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ID карточки товара:', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: productCardIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Название подкарточки:', style: formLabelStyle),
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

                  const Text('Брутто:', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bruttoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Нетто:', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nettoController,
                    keyboardType: TextInputType.number,
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
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
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
