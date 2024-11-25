import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AccountView extends StatefulWidget {
  const AccountView({Key? key}) : super(key: key);

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  File? _image;
  final picker = ImagePicker();
  String? photoUrl;
  String fullName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      photoUrl = prefs.getString('photo');
      final firstName = prefs.getString('first_name') ?? '';
      final lastName = prefs.getString('last_name') ?? '';
      fullName = '$firstName $lastName'.trim();
    });
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Upload the selected image to the server
  Future<void> _uploadImage() async {
    if (_image == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://yourapi.com/upload-photo'),
    );
    request.files.add(await http.MultipartFile.fromPath('photo', _image!.path));
    request.headers['Authorization'] = 'Bearer $token';

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      setState(() {
        photoUrl = data['photo'];
      });
      prefs.setString('photo', photoUrl!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with profile picture
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  color: Colors.black87,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : (photoUrl != null ? NetworkImage(photoUrl!) : null),
                    child: _image == null && photoUrl == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Settings Rows
            SettingsRow(
              title: "Добавить фото",
              trailing: null,
              onTap: _uploadImage,
            ),
            SettingsRow(
              title: "Push-уведомления",
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  setState(() {
                    // Toggle logic
                  });
                },
              ),
            ),
            SettingsRow(
              title: "Язык приложения",
              subtitle: "Русский",
              trailing: null,
              onTap: () {
                // Open language settings
              },
            ),
            SettingsRow(
              title: "Изменить пароль",
              trailing: null,
              onTap: () {
                // Open password settings
              },
            ),
            SettingsRow(
              title: "Блокирование скриншотов",
              subtitle: "Скриншоты разрешены для всех случаев",
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  setState(() {
                    // Toggle screenshot blocking
                  });
                },
              ),
            ),
            const Divider(),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Clear all saved data
                  Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      "Выйти",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings Row Widget
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
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
