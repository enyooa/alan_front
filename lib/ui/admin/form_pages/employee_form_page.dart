import 'package:cash_control/bloc/blocs/employee_bloc.dart';
import 'package:cash_control/bloc/events/employee_event.dart';
import 'package:cash_control/bloc/states/employee_state.dart';
import 'package:cash_control/ui/main/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/constant.dart';

class EmployeeFormPage extends StatefulWidget {
  @override
  _EmployeeFormPageState createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final TextEditingController positionController = TextEditingController();
  User? selectedUser;
  String? selectedRole;

  // Dictionary to translate roles into Russian
  final Map<String, String> rolesMap = {
    'cashbox': 'Касса',
    'courier': 'Курьер',
    'packer': 'Упаковщик',
    'client': 'Клиент',
    'admin': 'Администратор',
  };

  // Extract keys from the dictionary to use as actual values
  final List<String> roles = ['cashbox', 'courier', 'packer', 'client', 'admin'];

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(FetchUsersEvent());
  }
void _assignRole(BuildContext context) {
  if (selectedUser == null || selectedRole == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выберите пользователя и роль')),
    );
    return;
  }

  context.read<UserBloc>().add(
    AssignRoleEvent(userId: selectedUser!.id, role: selectedRole!),
  );
}

void _removeRole(BuildContext context, String role) {
  if (selectedUser == null) return;

  context.read<UserBloc>().add(
    RemoveRoleEvent(userId: selectedUser!.id, role: role),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Присвоить роль пользователю', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserRoleAssigned) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Роль успешно присвоена!')),
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Dropdown for selecting a user
                const Text(
                  'Выберите пользователя:',
                  style: subheadingStyle,
                ),
                const SizedBox(height: 10),
                DropdownButton<User>(
                  value: selectedUser,
                  hint: const Text('Выберите пользователя', style: bodyTextStyle),
                  items: state.users.map((user) {
                    return DropdownMenuItem(
                      value: user,
                      child: Text('${user.firstName} ${user.lastName}', style: bodyTextStyle),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUser = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Dropdown for selecting a role with Russian translation
                const Text(
                  'Выберите роль:',
                  style: subheadingStyle,
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedRole,
                  hint: const Text('Выберите роль', style: bodyTextStyle),
                  items: roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(rolesMap[role]!, style: bodyTextStyle),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () => _assignRole(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text('Присвоить роль', style: buttonTextStyle),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text('Не удалось загрузить пользователей', style: bodyTextStyle),
            );
          }
        },
      ),
    );
  }
}
