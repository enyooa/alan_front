import 'dart:io';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/account_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/account_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cash_control/constant.dart';

class AccountView extends StatefulWidget {
  const AccountView({Key? key}) : super(key: key);

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(FetchUserData());
  }

  Future<void> _pickAndUploadPhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      context.read<AccountBloc>().add(UploadPhoto(File(pickedFile.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AccountLoaded) {
          final userData = state.userData;
          final photoUrl = userData['photoUrl'];
          final fullName = userData['fullName'];
          final whatsappNumber = userData['whatsappNumber'];
          final isNotificationEnabled = userData['notifications'];

          return Scaffold(
            
            body: SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 200,
                        
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _pickAndUploadPhoto,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl.isEmpty
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            fullName,
                            style: titleStyle.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'WhatsApp: $whatsappNumber',
                            style: titleStyle.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SettingsRow(
                    title: "Push-уведомления",
                    trailing: Switch(
                      value: isNotificationEnabled,
                      onChanged: (value) {
                        context.read<AccountBloc>().add(ToggleNotification(value));
                      },
                    ),
                  ),
                  SettingsRow(
                    title: "Язык приложения",
                    subtitle: "Русский",
                    onTap: () {},
                  ),
                  SettingsRow(
                    title: "Изменить пароль",
                    onTap: () {},
                  ),
                  const Divider(height: 20, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AccountBloc>().add(Logout());
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: elevatedButtonStyle.copyWith(
                        backgroundColor: MaterialStateProperty.all(Colors.red.shade50),
                        foregroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout),
                          SizedBox(width: 10),
                          Text(
                            "Выйти",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is AccountError) {
          return Center(child: Text(state.message, style: bodyTextStyle));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(title, style: subheadingStyle),
        subtitle: subtitle != null ? Text(subtitle!, style: captionStyle) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
