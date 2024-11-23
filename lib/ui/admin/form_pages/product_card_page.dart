import 'dart:io';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_picker/image_picker.dart';
import 'package:cash_control/constant.dart';

class ProductCardPage extends StatefulWidget {
  @override
  _ProductCardPageState createState() => _ProductCardPageState();
}

class _ProductCardPageState extends State<ProductCardPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController bruttoController = TextEditingController();
  final TextEditingController nettoController = TextEditingController();
  File? selectedImage;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    countryController.dispose();
    typeController.dispose();
    bruttoController.dispose();
    nettoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveProduct() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final country = countryController.text.trim();
    final type = typeController.text.trim();
    final brutto = double.tryParse(bruttoController.text.trim()) ?? 0.0;
    final netto = double.tryParse(nettoController.text.trim()) ?? 0.0;

    if (name.isEmpty || brutto <= 0 || netto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все обязательные поля')),
      );
      return;
    }

    context.read<ProductCardBloc>().add(
          CreateProductCardEvent(
            nameOfProducts: name,
            description: description,
            country: country,
            type: type,
            brutto: brutto,
            netto: netto,
            photoProduct: selectedImage,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать карточку продукта', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocConsumer<ProductCardBloc, ProductCardState>(
        listener: (context, state) {
          if (state is ProductCardSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProductCardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductCardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildTextField(nameController, 'Название продукта'),
                _buildTextField(descriptionController, 'Описание'),
                _buildTextField(countryController, 'Страна'),
                _buildTextField(typeController, 'Тип'),
                _buildTextField(bruttoController, 'Брутто', isNumber: true),
                _buildTextField(nettoController, 'Нетто', isNumber: true),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      icon: const Icon(Icons.upload_file, color: Colors.white), // Icon for upload
                      label: const Text('Выбрать изображение', style: buttonTextStyle),
                    ),
                    ElevatedButton.icon(
                      onPressed: _takePhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      icon: const Icon(Icons.camera_alt, color: Colors.white), // Icon for take photo
                      label: const Text('Сделать фото', style: buttonTextStyle),
                    ),
                  ],
                ),
                if (selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Image.file(selectedImage!, height: 150),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text('Сохранить продукт', style: buttonTextStyle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: subheadingStyle,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: bodyTextStyle,
      ),
    );
  }
}
