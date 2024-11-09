import 'package:cash_control/bloc/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/events/auth_event.dart';
import 'package:cash_control/bloc/states/auth_state.dart';
import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/main/auth/password_verification.dart';
import 'package:cash_control/ui/main/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _whatsappNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            switch (state.role) {
              case 'admin':
                Navigator.pushReplacementNamed(context, '/admin_dashboard');
                break;
              case 'cashbox':
                Navigator.pushReplacementNamed(context, '/cashbox_dashboard');
                break;
              case 'client':
                Navigator.pushReplacementNamed(context, '/client_dashboard');
                break;
              case 'packer':
                Navigator.pushReplacementNamed(context, '/packer_dashboard');
                break;
              default:
                Navigator.pushReplacementNamed(context, '/home');
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView( // Wrap main content to make it scrollable
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                SizedBox(height: MediaQuery.of(context).size.height / 4),
                const Text(
                  'Логин',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 27,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),
                TextField(
                  controller: _whatsappNumberController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp номер',
                    labelStyle: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(width: 1, color: primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(width: 1, color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(width: 1, color: primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(width: 1, color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final whatsappNumber = _whatsappNumberController.text.trim();
                        final password = _passwordController.text.trim();

                        if (whatsappNumber.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter all fields')),
                          );
                        } else {
                          BlocProvider.of<AuthBloc>(context).add(
                            LoginEvent(whatsapp_number: whatsappNumber, password: password),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: const Text(
                        'Войти',
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
                  children: [
                    const Text(
                      'У вас нет еще аккаунта?',
                      style: TextStyle(
                        color: Color(0xFF837E93),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );                      },
                      child: const Text(
                        'Регистрация',
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
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PasswordVerificationScreen()),
                    );
                  },
                  child: const Text(
                    'Забыли пароль?',
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
          ),
        ),
      ),
    );
  }
}
