import 'package:alan/ui/main/auth/sms_verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// BLoCs
import 'package:alan/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/states/auth_state.dart';
import 'package:alan/bloc/blocs/common_blocs/events/register_event.dart';

// Styles/constants
import 'package:alan/constant.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _whatsappNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();

  // Loading flag to show a circular indicator
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthNotVerified) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Номер не подтвержден, пожалуйста, введите код.')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SmsVerificationScreen(rawPhone: state.rawPhone),
              ),
            );
          } else if (state is AuthAuthenticated) {
            setState(() => _isLoading = false);
            Navigator.pushReplacementNamed(context, '/client_dashboard');
          } else if (state is AuthError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              SizedBox(height: MediaQuery.of(context).size.height / 6),
              const Text(
                'Регистрация',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 27,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(_firstNameController, 'Имя'),
              const SizedBox(height: 15),
              _buildTextField(_lastNameController, 'Фамилия'),
              const SizedBox(height: 15),
              _buildTextField(_surnameController, 'Отчество'),
              const SizedBox(height: 15),
              _buildTextField(_whatsappNumberController, 'WhatsApp номер'),
              const SizedBox(height: 15),
              _buildPasswordField(_passwordController, 'Пароль'),
              const SizedBox(height: 15),
              _buildPasswordField(_passwordConfirmationController, 'Подтверждение пароля'),
              const SizedBox(height: 25),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onRegisterPressed,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Зарегистрироваться',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Уже есть аккаунт?',
                    style: TextStyle(
                      color: Color(0xFF837E93),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Войти',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRegisterPressed() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final surname = _surnameController.text.trim();
    final whatsappNumber = _whatsappNumberController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirmation = _passwordConfirmationController.text.trim();

    if ([firstName, whatsappNumber, password, passwordConfirmation].any((field) => field.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста заполните все поля!')),
      );
    } else if (password != passwordConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль не совпадает')),
      );
    } else {
      setState(() => _isLoading = true);
      context.read<AuthBloc>().add(
        RegisterEvent(
          firstName: firstName,
          lastName: lastName,
          surname: surname,
          whatsappNumber: whatsappNumber,
          password: password,
          passwordConfirmation: passwordConfirmation,
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: primaryColor,
        fontSize: 13,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 15,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: primaryColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: primaryColor),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      obscureText: true,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: primaryColor,
        fontSize: 13,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 15,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: primaryColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: primaryColor),
        ),
      ),
    );
  }
}
