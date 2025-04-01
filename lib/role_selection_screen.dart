// lib/role_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alan/constant.dart';  // <-- to use your colors & text styles

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  List<String> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  /// Loads roles from SharedPreferences.
  Future<void> _loadRoles() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _roles = prefs.getStringList('roles') ?? [];
    });
  }

  /// Map the user’s role to its correct dashboard route
  void _navigateToDashboard(String role) {
    switch (role) {
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
      case 'storager':
        Navigator.pushReplacementNamed(context, '/storage_dashboard');
        break;
      case 'courier':
        Navigator.pushReplacementNamed(context, '/courier_dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }

  /// For a nice label in Russian (or any language)
  String _mapRoleToDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Администратор';
      case 'cashbox':
        return 'Кассир';
      case 'client':
        return 'Клиент';
      case 'packer':
        return 'Упаковщик';
      case 'storager':
        return 'Кладовщик';
      case 'courier':
        return 'Курьер';
      default:
        return role;
    }
  }

  /// Optionally show icons for each role
  IconData _mapRoleToIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'cashbox':
        return Icons.point_of_sale;
      case 'client':
        return Icons.shopping_cart;
      case 'packer':
        return Icons.inventory_2;
      case 'storager':
        return Icons.warehouse;
      case 'courier':
        return Icons.delivery_dining;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no roles found, just show a placeholder screen
    if (_roles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Выбор роли', style: headingStyle),
        ),
        body: const Center(
          child: Text('Нет доступных ролей...', style: bodyTextStyle),
        ),
      );
    }

    // If we do have multiple roles, display them
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Выбор роли', style: headingStyle),
        centerTitle: true,
      ),
      body: Padding(
        padding: pagePadding,
        child: ListView.builder(
          itemCount: _roles.length,
          itemBuilder: (context, index) {
            final role = _roles[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _navigateToDashboard(role),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(_mapRoleToIcon(role), color: primaryColor, size: 32),
                      const SizedBox(width: 16),
                      Text(
                        _mapRoleToDisplayName(role),
                        style: subheadingStyle,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
