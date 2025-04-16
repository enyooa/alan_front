import 'package:alan/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/auth_state.dart';
import 'package:alan/constant.dart';
import 'package:alan/ui/main/auth/password_verification.dart';
import 'package:alan/ui/main/auth/register.dart';
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

  bool _obscurePassword = true; // Control password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // The user is logged in; route them based on their roles.
            final roles = state.roles;

            if (roles.isEmpty) {
              Navigator.pushReplacementNamed(context, '/login');
            } else if (roles.length == 1) {
              final singleRole = roles.first;
              switch (singleRole) {
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
                case 'courier':
                  Navigator.pushReplacementNamed(context, '/courier_dashboard');
                  break;
                case 'storager':
                  Navigator.pushReplacementNamed(context, '/storage_dashboard');
                  break;
                default:
                  Navigator.pushReplacementNamed(context, '/login');
                  break;
              }
            } else {
              // 2+ roles => show the Role Selection screen
              Navigator.pushReplacementNamed(context, '/role_selection');
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
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

                // WhatsApp Number Input with +7 prefix
                TextField(
                  controller: _whatsappNumberController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '+7 ',
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

                // Password Input with Eye Icon
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Пароль',
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Login Button
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final typedNumber = _whatsappNumberController.text.trim();
                        final password = _passwordController.text.trim();

                        if (typedNumber.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Пожалуйста заполните все поля!')),
                          );
                        } else {
                          // No extra '7' prefix here:
                          BlocProvider.of<AuthBloc>(context).add(
                            LoginEvent(
                              whatsapp_number: typedNumber,  // use it as-is
                              password: password,
                            ),
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
                          MaterialPageRoute(builder: (context) => const Register()),
                        );
                      },
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
                      MaterialPageRoute(builder: (context) =>  PasswordVerificationScreen()),
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
