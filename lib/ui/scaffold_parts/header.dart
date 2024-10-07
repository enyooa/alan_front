import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  // Remove the unnecessary local variable _title
  final String title; // Use 'final' for immutable fields

  const Header({
    Key? key,
    required this.title,
  }) : super(key: key);

  // Build supplier header section
  Container buildSupplierHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.blueAccent,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Call the 'buildSupplierHeader' method inside the 'build' method to render it
    return buildSupplierHeader(title);
  }
}
