// EditProductCardPage.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:alan/constant.dart';
import 'package:image_picker/image_picker.dart';

class EditProductCardPage extends StatefulWidget {
  final int productId;
  final String? existingPhotoUrl; // optional, if you want to pass a known photo

  const EditProductCardPage({
    Key? key,
    required this.productId,
    this.existingPhotoUrl,
  }) : super(key: key);

  @override
  _EditProductCardPageState createState() => _EditProductCardPageState();
}

class _EditProductCardPageState extends State<EditProductCardPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  File? photoProduct;
  final ImagePicker _picker = ImagePicker();
  bool _didLoadData = false; // ensure we only set text fields once

  @override
  void initState() {
    super.initState();
    // Immediately fetch the actual data from server
    context.read<ProductCardBloc>().add(
      FetchSingleProductCardEvent(widget.productId),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    countryController.dispose();
    typeController.dispose();
    super.dispose();
  }

  Future<void> _pickImageGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => photoProduct = File(picked.path));
    }
  }

  Future<void> _pickImageCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => photoProduct = File(picked.path));
    }
  }

  void _save() {
    final updatedFields = <String, String>{
      'name_of_products': nameController.text,
      'description': descriptionController.text,
      'country': countryController.text,
      'type': typeController.text,
    };

    context.read<ProductCardBloc>().add(
      UpdateProductCardEvent(
        id: widget.productId,
        updatedFields: updatedFields,
        photoFile: photoProduct,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductCardBloc, ProductCardState>(
      listener: (context, state) {
        if (state is ProductCardCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context, true); 
        } else if (state is ProductCardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<ProductCardBloc, ProductCardState>(
        builder: (context, state) {
          final isLoading = state is ProductCardLoading;

          // Once single product data is loaded, fill fields if not done yet
          if (state is SingleProductCardLoaded && !_didLoadData) {
            final data = state.productCard;
            nameController.text = data['name_of_products'] ?? '';
            descriptionController.text = data['description'] ?? '';
            countryController.text = data['country'] ?? '';
            typeController.text = data['type'] ?? '';
            _didLoadData = true;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Редактировать карточку товара', style: headingStyle),
              backgroundColor: primaryColor,
            ),
            body: SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Название', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Описание', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Страна', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: countryController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Тип', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: typeController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Show existingPhotoUrl if we have it, else if a new photo is chosen
                  if (widget.existingPhotoUrl != null && photoProduct == null) ...[
                    Image.network(widget.existingPhotoUrl!),
                    const SizedBox(height: 12),
                  ] else if (photoProduct != null) ...[
                    Image.file(photoProduct!, height: 100),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _pickImageGallery,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                          ),
                          icon: const Icon(Icons.photo_library,
                              size: 16, color: Colors.white),
                          label: const Text('Выбрать фото', style: buttonTextStyle),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _pickImageCamera,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                          ),
                          icon: const Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                          label: const Text('Сделать фото', style: buttonTextStyle),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.send, color: Colors.white),
                    label: const Text('Сохранить', style: buttonTextStyle),
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
