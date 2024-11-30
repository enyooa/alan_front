import 'package:cash_control/bloc/blocs/provider_bloc.dart';
import 'package:cash_control/bloc/events/provider_event.dart';
import 'package:cash_control/bloc/states/provider_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cash_control/constant.dart';

class ProviderPage extends StatefulWidget {
  @override
  _ProviderPageState createState() => _ProviderPageState();
}

class _ProviderPageState extends State<ProviderPage> {
  final TextEditingController providerNameController = TextEditingController();

  @override
  void dispose() {
    providerNameController.dispose();
    super.dispose();
  }

  void _saveProvider(BuildContext context) {
    final providerName = providerNameController.text.trim();

    if (providerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите наименование поставщика')),
      );
      return;
    }

    context.read<ProviderBloc>().add(CreateProviderEvent(name: providerName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать Поставщика', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocConsumer<ProviderBloc, ProviderState>(
        listener: (context, state) {
          if (state is ProviderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            providerNameController.clear();
          } else if (state is ProviderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProviderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildTextField(providerNameController, 'Наименование поставщика'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _saveProvider(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text('Сохранить', style: buttonTextStyle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: subheadingStyle,
          border: const OutlineInputBorder(),
        ),
        style: bodyTextStyle,
      ),
    );
  }
}
