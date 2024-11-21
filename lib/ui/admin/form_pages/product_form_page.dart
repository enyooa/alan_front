import 'dart:convert';
import 'dart:io';
import 'package:cash_control/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cash_control/bloc/blocs/product_bloc.dart';
import 'package:cash_control/bloc/events/product_event.dart';
import 'package:cash_control/bloc/states/product_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void dispose() {
    productNameController.dispose();
    productDescriptionController.dispose();
    countryController.dispose();
    typeController.dispose();
    bruttoController.dispose();
    nettoController.dispose();
    super.dispose();
  }

  Future<void> _chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

Future<void> _saveProduct(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final roles = prefs.getStringList('roles') ?? [];

  if (token == null || !roles.contains('admin')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отказ в доступе: Только админ может создать карточку товара')),
    );
    return;
  }

  final String name = productNameController.text.trim();
  final String description = productDescriptionController.text.trim();
  final String country = countryController.text.trim();
  final String type = typeController.text.trim();
  final double brutto = double.tryParse(bruttoController.text.trim()) ?? 0.0;
  final double netto = double.tryParse(nettoController.text.trim()) ?? 0.0;
  final File? photoFile = selectedImage;

  // Validate required fields
  if (name.isEmpty || brutto <= 0 || netto <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all required fields')),
    );
    return;
  }

  // Create request
  final uri = Uri.parse(baseUrl + 'product_card_create');
  final request = MultipartRequest('POST', uri);

  // Add headers
  request.headers['Authorization'] = 'Bearer $token';

  // Add fields
  request.fields['name_of_products'] = name;
  request.fields['description'] = description;
  request.fields['country'] = country;
  request.fields['type'] = type;
  request.fields['brutto'] = brutto.toString();
  request.fields['netto'] = netto.toString();

  // Add file if exists
  if (photoFile != null) {
    request.files.add(await MultipartFile.fromPath('photo_product', photoFile.path));
  }

  // Send request
  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created successfully')),
      );
      _clearFields();
    } else {
      final data = jsonDecode(responseBody);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed to create product')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error while creating product: $error')),
    );
  }
}

// Clear input fields
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

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать продукт', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Продукт успешно создан')),
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
                _buildTextField(productNameController, 'Наименование товара'),
                _buildTextField(productDescriptionController, 'Характеристика'),
                _buildTextField(countryController, 'Страна'),
                _buildTextField(typeController, 'Тип'),
                _buildTextField(bruttoController, 'Brutto', isNumber: true),
                _buildTextField(nettoController, 'Netto', isNumber: true),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _chooseImage,
                      child: const Text('Выбрать из галереи', style: buttonTextStyle),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _takePhoto,
                      child: const Text('Сделать фото', style: buttonTextStyle),
                    ),
                  ],
                ),
                if (selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Image.file(selectedImage!, height: 150),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _saveProduct(context),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text('Сохранить', style: buttonTextStyle),
                ),
              ],
            );
          },
        ),
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
