import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:cash_control/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductSubCardPage extends StatefulWidget {
  @override
  _ProductSubCardPageState createState() => _ProductSubCardPageState();
}

class _ProductSubCardPageState extends State<ProductSubCardPage> {
  final TextEditingController quantitySoldController = TextEditingController();
  final TextEditingController priceAtSaleController = TextEditingController();

  int? selectedProductCardId;

  @override
  void initState() {
    super.initState();
    // Fetch product cards when the page loads
    context.read<ProductCardBloc>().add(FetchProductCardsEvent());
  }

  void _saveSubCard() {
    if (selectedProductCardId == null) {
      _showSnackBar('Выберите карточку продукта.');
      return;
    }

    final quantitySold = double.tryParse(quantitySoldController.text.trim());
    final priceAtSale = int.tryParse(priceAtSaleController.text.trim());

    if (quantitySold == null || priceAtSale == null) {
      _showSnackBar('Заполните все поля корректно.');
      return;
    }

    context.read<ProductSubCardBloc>().add(
          CreateProductSubCardEvent(
            productCardId: selectedProductCardId!,
            quantitySold: quantitySold,
            priceAtSale: priceAtSale,
          ),
        );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    quantitySoldController.dispose();
    priceAtSaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать подкарточку', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocListener<ProductSubCardBloc, ProductSubCardState>(
        listener: (context, state) {
          if (state is ProductSubCardSuccess) {
            _showSnackBar(state.message);
            _clearFields();
          } else if (state is ProductSubCardError) {
            _showSnackBar(state.error);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              BlocBuilder<ProductCardBloc, ProductCardState>(
                builder: (context, state) {
                  if (state is ProductCardLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductCardLoaded) {
                    return DropdownButtonFormField<int>(
                      value: selectedProductCardId,
                      decoration: InputDecoration(
                        labelText: 'Выберите карточку продукта',
                        labelStyle: subheadingStyle,
                        border: const OutlineInputBorder(),
                      ),
                      items: state.productCards.map((productCard) {
                        return DropdownMenuItem(
                          value: productCard.id,
                          child: Text(
                            productCard.nameOfProducts,
                            style: bodyTextStyle,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProductCardId = value;
                        });
                      },
                    );
                  } else if (state is ProductCardError) {
                    return Center(
                      child: Text(
                        state.error,
                        style: bodyTextStyle.copyWith(color: Colors.red),
                      ),
                    );
                  }
                  return const Center(
                    child: Text(
                      'Ошибка при загрузке карточек продуктов',
                      style: bodyTextStyle,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: quantitySoldController,
                label: 'Количество продано',
                isNumber: true,
              ),
              _buildTextField(
                controller: priceAtSaleController,
                label: 'Цена при продаже',
                isNumber: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSubCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: const Text('Сохранить подкарточку', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
  }) {
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

  void _clearFields() {
    quantitySoldController.clear();
    priceAtSaleController.clear();
    setState(() {
      selectedProductCardId = null;
    });
  }
}
