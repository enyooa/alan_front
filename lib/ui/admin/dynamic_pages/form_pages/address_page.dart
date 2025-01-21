import 'package:alan/bloc/blocs/admin_page_blocs/blocs/address_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/address_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/address_state.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/employee_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/employee_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/employee_state.dart';
import 'package:alan/ui/main/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/constant.dart';
class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final TextEditingController nameController = TextEditingController();
  int? selectedUserId;
  @override
  void initState() {
    // TODO: implement initState
    context.read<UserBloc>().add(FetchUsersEvent());

  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        
        BlocProvider<AddressBloc>(
          create: (_) => AddressBloc(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Создать адрес', style: headingStyle),
          backgroundColor: primaryColor,
        ),
        body: BlocListener<AddressBloc, AddressState>(
          listener: (context, state) {
            if (state is AddressCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              nameController.clear();
              setState(() {
                selectedUserId = null;
              });
            } else if (state is AddressError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              return SingleChildScrollView(
                padding: pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Выберите пользователя', style: formLabelStyle),
                    const SizedBox(height: 8),
                    if (userState is UsersLoaded)
                      DropdownButtonFormField<int>(
                        value: selectedUserId,
                        hint: const Text('Выберите пользователя', style: bodyTextStyle),
                        items: userState.users.map((user) {
                          return DropdownMenuItem<int>(
                            value: user.id,
                            child: Text(user.firstName, style: bodyTextStyle),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUserId = value;
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
                    else if (userState is UserLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      const Text('Не удалось загрузить пользователей', style: bodyTextStyle),
                    const SizedBox(height: 12),
                    const Text('Название адреса', style: formLabelStyle),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Введите название адреса',
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
                        if (selectedUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Выберите пользователя')),
                          );
                          return;
                        }

                        if (nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Введите название адреса')),
                          );
                          return;
                        }

                        context.read<AddressBloc>().add(
                          CreateAddressEvent(
                            userId: selectedUserId!,
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
