import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/constant.dart';

class ProductSubCardPage extends StatefulWidget {
  @override
  _ProductSubCardPageState createState() => _ProductSubCardPageState();
}

class _ProductSubCardPageState extends State<ProductSubCardPage> {
  final TextEditingController nameController = TextEditingController();

  int? selectedProductCardId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductCardBloc>(
          create: (_) => ProductCardBloc()..add(FetchProductCardsEvent()),
        ),
        BlocProvider<ProductSubCardBloc>(
          create: (_) => ProductSubCardBloc(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Создать подкарточку', style: headingStyle),
          backgroundColor: primaryColor,
        ),
        body: BlocListener<ProductSubCardBloc, ProductSubCardState>(
          listener: (context, state) {
            if (state is ProductSubCardCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              // Clear input fields after successful creation
              nameController.clear();
              
              setState(() {
                selectedProductCardId = null;
              });
            } else if (state is ProductSubCardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<ProductCardBloc, ProductCardState>(
            builder: (context, productCardState) {
              return SingleChildScrollView(
                padding: pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Выберите карточку', style: formLabelStyle),
                    const SizedBox(height: 8),
                    if (productCardState is ProductCardsLoaded)
                      DropdownButtonFormField<int>(
                        value: selectedProductCardId,
                        hint: const Text('Выберите карточку', style: bodyTextStyle),
                        items: productCardState.productCards.map((productCard) {
                          return DropdownMenuItem<int>(
                            value: productCard['id'],
                            child: Text(
                              productCard['name_of_products'] ?? 'Unnamed Product Card',
                              style: bodyTextStyle,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProductCardId = value;
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      )
                    else if (productCardState is ProductCardLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      const Text(
                        'Не удалось загрузить карточки',
                        style: bodyTextStyle,
                      ),
                    const SizedBox(height: 12),

                    const Text('Название', style: formLabelStyle),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Введите название',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                   
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () {
                        if (selectedProductCardId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Выберите карточку')),
                          );
                          return;
                        }

                        if (nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Введите название')),
                          );
                          return;
                        }

                        context.read<ProductSubCardBloc>().add(
                          CreateProductSubCardEvent(
                            productCardId: selectedProductCardId!,
                            name: nameController.text,
                           
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
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('Отправить', style: buttonTextStyle),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
