import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cash_control/bloc/blocs/product_bloc.dart';
import 'package:cash_control/bloc/events/product_event.dart';
import 'package:cash_control/bloc/states/product_state.dart';

class ProductFormPage extends StatefulWidget {
  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  // Controllers for product fields
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productDescriptionController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController bruttoController = TextEditingController();
  final TextEditingController nettoController = TextEditingController();

  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  // Function to choose a photo from the gallery
  Future<void> _chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to save the product
  void _saveProduct(BuildContext context) {
    final String name = productNameController.text.trim();
    final String description = productDescriptionController.text.trim();
    final String country = countryController.text.trim();
    final String type = typeController.text.trim();
    final double brutto = double.tryParse(bruttoController.text.trim()) ?? 0.0;
    final double netto = double.tryParse(nettoController.text.trim()) ?? 0.0;

    if (name.isEmpty || brutto <= 0 || netto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    context.read<ProductBloc>().add(
      CreateProductEvent(
        name: name,
        description: description,
        country: country,
        type: type,
        brutto: brutto,
        netto: netto,
        photo: selectedImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product created successfully')),
              );
              _clearFields();
            } else if (state is ProductError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: [
                TextField(
                  controller: productNameController,
                  decoration: const InputDecoration(labelText: 'Наименование товара'),
                ),
                TextField(
                  controller: productDescriptionController,
                  decoration: const InputDecoration(labelText: 'Характеристика'),
                ),
                TextField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Страна'),
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Тип'),
                ),
                TextField(
                  controller: bruttoController,
                  decoration: const InputDecoration(labelText: 'Brutto'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: nettoController,
                  decoration: const InputDecoration(labelText: 'Netto'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _chooseImage,
                  child: const Text('Choose Image'),
                ),
                if (selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Image.file(selectedImage!, height: 150),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _saveProduct(context),
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Function to clear the form fields after successful submission
  void _clearFields() {
    productNameController.clear();
    productDescriptionController.clear();
    countryController.clear();
    typeController.clear();
    bruttoController.clear();
    nettoController.clear();
    setState(() {
      selectedImage = null;
    });
  }
}
