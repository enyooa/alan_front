import 'dart:io';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/constant.dart';
import 'package:image_picker/image_picker.dart';

class ProductCardPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  File? photoProduct;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductCardBloc(),
      child: BlocListener<ProductCardBloc, ProductCardState>(
        listener: (context, state) {
          if (state is ProductCardCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProductCardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<ProductCardBloc, ProductCardState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Создать карточку товара', style: headingStyle),
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
                        hintText: 'Введите название продукта',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
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
                        hintText: 'Введите описание',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
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
                        hintText: 'Введите страну',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
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
                        hintText: 'Введите тип',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final imagePicker = ImagePicker();
                              final pickedImage = await imagePicker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedImage != null) {
                                photoProduct = File(pickedImage.path);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                            ),
                            icon: const Icon(Icons.photo_library, size: 16,color: Colors.white,),
                            label: const Text('Выбрать фото', style: buttonTextStyle),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final imagePicker = ImagePicker();
                              final pickedImage = await imagePicker.pickImage(
                                  source: ImageSource.camera);
                              if (pickedImage != null) {
                                photoProduct = File(pickedImage.path);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                            ),
                            icon: const Icon(Icons.camera_alt, size: 16,color: Colors.white,),
                            label: const Text('Сделать фото', style: buttonTextStyle),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () {
                        BlocProvider.of<ProductCardBloc>(context).add(
                          CreateProductCardEvent(
                            nameOfProducts: nameController.text,
                            description: descriptionController.text,
                            country: countryController.text,
                            type: typeController.text,
                            photoProduct: photoProduct,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: state is ProductCardLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.send,color: Colors.white,),
                      label: const Text('Отправить', style: buttonTextStyle),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
