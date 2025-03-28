import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import your constant.dart here:
import 'package:alan/constant.dart';

class SmsVerificationScreen extends StatefulWidget {
  final String rawPhone; // e.g. "87076069831"
  const SmsVerificationScreen({Key? key, required this.rawPhone}) : super(key: key);

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final TextEditingController _digit1Controller = TextEditingController();
  final TextEditingController _digit2Controller = TextEditingController();
  final TextEditingController _digit3Controller = TextEditingController();
  final TextEditingController _digit4Controller = TextEditingController();

  final FocusNode _digit1Focus = FocusNode();
  final FocusNode _digit2Focus = FocusNode();
  final FocusNode _digit3Focus = FocusNode();
  final FocusNode _digit4Focus = FocusNode();

  bool isLoading = false;

  /// Format "87076069831" => "7076069831"
  String get formattedPhone {
    String phone = widget.rawPhone.trim();
    if (phone.startsWith('8')) {
      phone = phone.substring(1); // remove leading '8'
    }
    return phone;
  }

  @override
  void initState() {
    super.initState();
    _sendCodeOnInit();
  }

  Future<void> _sendCodeOnInit() async {
    final url = Uri.parse(baseUrl+'send_verification_code');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': formattedPhone}),
    );
  }

  Future<void> _verifyCode() async {
    // Combine the digits
    final code = _digit1Controller.text.trim() +
        _digit2Controller.text.trim() +
        _digit3Controller.text.trim() +
        _digit4Controller.text.trim();

    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите все 4 цифры!')),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse(baseUrl+'verify_code');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': formattedPhone,
        'code': code,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Успешно подтверждено!')),
      );
      Navigator.pushReplacementNamed(context, '/client_dashboard');
    } else {
      final errorJson = jsonDecode(response.body);
      final errorMsg = errorJson['message'] ?? 'Неверный код';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // from constant.dart
      appBar: AppBar(
        title: const Text('Подтвердите номер', style: headingStyle),
        backgroundColor: primaryColor,  // from constant.dart
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: pagePadding, // from constant.dart
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
              Text(
                'Мы отправили код на номер: $formattedPhone',
                style: subheadingStyle.copyWith(color: textColor),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // A card-like container for the code input
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Введите 4-значный код',
                        style: subheadingStyle,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDigitField(
                            controller: _digit1Controller,
                            currentFocus: _digit1Focus,
                            nextFocus: _digit2Focus,
                          ),
                          _buildDigitField(
                            controller: _digit2Controller,
                            currentFocus: _digit2Focus,
                            nextFocus: _digit3Focus,
                          ),
                          _buildDigitField(
                            controller: _digit3Controller,
                            currentFocus: _digit3Focus,
                            nextFocus: _digit4Focus,
                          ),
                          // For the last one, we can move focus away or do something else
                          _buildDigitField(
                            controller: _digit4Controller,
                            currentFocus: _digit4Focus,
                            nextFocus: _digit4Focus, // or FocusNode() if you have a separate "done" FocusNode
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isLoading ? null : _verifyCode,
                        style: elevatedButtonStyle, // from constant.dart
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Подтвердить', style: buttonTextStyle),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // A "Resend code" section, if desired
              Center(
                child: TextButton(
                  onPressed: _sendCodeOnInit,
                  child: const Text(
                    'Отправить код повторно',
                    style: subheadingStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for each 1-digit field
  Widget _buildDigitField({
  required TextEditingController controller,
  required FocusNode currentFocus,
  required FocusNode nextFocus,
}) {
  return SizedBox(
    width: 50,
    child: TextField(
      controller: controller,
      focusNode: currentFocus,
      maxLength: 1,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        counterText: '', // Hide the "0/1" under field
      ),
      onChanged: (value) {
        if (value.length == 1) {
          // Automatically move to next field
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
    ),
  );
}
}
