import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cash_control/constant.dart';

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
  String whatsappNumber = '';

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
      final surname = prefs.getString('surname') ?? '';
      fullName = '$firstName $lastName $surname'.trim();
      whatsappNumber = prefs.getString('whatsapp_number') ?? '';
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
      Uri.parse('$baseUrl/upload-photo'),
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
      appBar: AppBar(title: const Text('Account')),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile photo
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (photoUrl != null ? NetworkImage(photoUrl!) : null),
                  child: _image == null && photoUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text('Загрузить фото'),
              ),
              const SizedBox(height: 20),
              // Display full name
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              // Display WhatsApp number
              Text(
                'WhatsApp: $whatsappNumber',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              // Additional Account Settings or Options
              AccountRow(
                title: "Order History",
                icon: "assets/img/a_order.png",
                onPressed: () {},
              ),
              AccountRow(
                title: "Delivery Addresses",
                icon: "assets/img/a_delivery_address.png",
                onPressed: () {},
              ),
              AccountRow(
                title: "Payment Methods",
                icon: "assets/img/payment_methods.png",
                onPressed: () {},
              ),
              AccountRow(
                title: "Notifications",
                icon: "assets/img/a_notification.png",
                onPressed: () {},
              ),
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
                    backgroundColor: Colors.blue.shade50,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/img/logout.png",
                        width: 24,
                        height: 24,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget for each account row
class AccountRow extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onPressed;

  const AccountRow({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Image.asset(
        icon,
        width: 30,
        height: 30,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onPressed,
    );
  }
}
