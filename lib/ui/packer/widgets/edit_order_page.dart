import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/constant.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/packer_order_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/packer_order_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/packer_order_state.dart';

class EditOrderPage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  const EditOrderPage({Key? key, required this.orderDetails})
      : super(key: key);

  @override
  _EditOrderPageState createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  // Example controller for products; adjust according to your data structure.
  late TextEditingController _productsController;

  @override
  void initState() {
    super.initState();
    _addressController =
        TextEditingController(text: widget.orderDetails['address'] ?? '');
    // For this example, we assume order_products is a list of product names or quantities.
    _productsController = TextEditingController(
        text: widget.orderDetails['order_products']?.join(', ') ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    _productsController.dispose();
    super.dispose();
  }

  void _submitEdit() {
    if (_formKey.currentState!.validate()) {
      // Construct updatedProducts – here we simply use a dummy list.
      // In a real-world scenario, you’d build a list based on the edited fields.
      final updatedProducts = [
        {
          'order_item_id': widget.orderDetails['id'],
          'packer_quantity': int.tryParse(_productsController.text) ?? 0
        }
      ];
      // Dispatch the update event
      BlocProvider.of<PackerOrdersBloc>(context).add(
        UpdateOrderDetailsEvent(
          orderId: widget.orderDetails['id'],
          updatedProducts: updatedProducts,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать заявку'),
        backgroundColor: primaryColor,
      ),
      body: BlocListener<PackerOrdersBloc, PackerOrdersState>(
        listener: (context, state) {
          if (state is UpdateOrderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is UpdateOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(horizontalPadding),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Address Field
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Адрес'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите адрес';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Products Field (as an example input)
                TextFormField(
                  controller: _productsController,
                  decoration: const InputDecoration(
                      labelText: 'Продукты (количество)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите продукты';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: _submitEdit,
                  child: const Text('Сохранить', style: buttonTextStyle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
