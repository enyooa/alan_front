import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/financial_element.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_element.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/financial_element.dart';
import 'package:alan/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReferenceScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReferenceBloc, ReferenceState>(
      builder: (context, state) {
        if (state.isLoading) return Center(child: CircularProgressIndicator());
        if (state.errorMessage != null) return Center(child: Text(state.errorMessage!, style: bodyTextStyle));

        return ListView(
          padding: pagePadding,
          children: state.references.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;

            return Card(
              margin: EdgeInsets.only(bottom: verticalPadding),
              elevation: 2,
              child: Padding(
                padding: elementPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category,
                          style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.add, color: primaryColor),
                          onPressed: () => _showDialog(context, category),
                        ),
                      ],
                    ),
                    Divider(color: borderColor),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index]; // Each item is now a Map with 'id' and 'name'
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  item['name'], // Use 'name' for display
                                  style: bodyTextStyle,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: primaryColor),
                              onPressed: () => _showDialog(context, category, index: index, initialValue: item['name']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: errorColor),
                              onPressed: () =>
                                  context.read<ReferenceBloc>().add(DeleteReferenceEvent(category, index)),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showDialog(BuildContext context, String category, {int? index, String? initialValue}) {
    _controller.text = initialValue ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            index == null ? 'Добавить' : 'Редактировать',
            style: subheadingStyle,
          ),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Введите значение',
              hintStyle: bodyTextStyle.copyWith(color: unselectednavbar),
            ),
            style: bodyTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена', style: buttonTextStyle.copyWith(color: errorColor)),
            ),
            TextButton(
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  if (index == null) {
                    context.read<ReferenceBloc>().add(AddReferenceEvent(category, text));
                  } else {
                    context.read<ReferenceBloc>().add(EditReferenceEvent(category, index, text));
                  }
                  Navigator.pop(context);
                }
              },
              child: Text('Сохранить', style: buttonTextStyle.copyWith(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }
}