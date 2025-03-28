
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/provider_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/provider_state.dart';
import 'package:alan/constant.dart';

class EditProviderPage extends StatefulWidget {
  final int providerId;

  const EditProviderPage({Key? key, required this.providerId}) : super(key: key);

  @override
  _EditProviderPageState createState() => _EditProviderPageState();
}

class _EditProviderPageState extends State<EditProviderPage> {
  final TextEditingController nameController = TextEditingController();
  bool _didLoadData = false;

  @override
  void initState() {
    super.initState();
    // 1) fetch single
    context.read<ProviderBloc>().add(
      FetchSingleProviderEvent(id: widget.providerId),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название поставщика')),
      );
      return;
    }

    // 2) dispatch update
    context.read<ProviderBloc>().add(
      UpdateProviderEvent(id: widget.providerId, name: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProviderBloc, ProviderState>(
      listener: (context, state) {
        if (state is ProviderSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context, true);
        } else if (state is ProviderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: BlocBuilder<ProviderBloc, ProviderState>(
        builder: (context, state) {
          final isLoading = state is ProviderLoading;

          // 3) Fill once data is loaded
          if (state is SingleProviderLoaded && !_didLoadData) {
            final providerData = state.providerData;
            // e.g. providerData => { "id":..., "name": "My Provider" }
            nameController.text = providerData['name'] ?? '';
            _didLoadData = true;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Редактировать поставщика', style: headingStyle),
              backgroundColor: primaryColor,
            ),
            body: SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Название поставщика:', style: formLabelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Сохранить', style: buttonTextStyle),
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
