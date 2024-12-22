import 'package:flutter/material.dart';
import 'package:cash_control/constant.dart'; // Import constants

class CourierScreen extends StatelessWidget {
  const CourierScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> couriers = const [
    {'name': 'Асенов Асенов', 'location': 'Магнум Сыганак 44'},
    {'name': 'Хасан Хасанович', 'location': 'Магнум Турган 55'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Курьеры',
          style: headingStyle, // Use headingStyle from constants
        ),
        backgroundColor: primaryColor, // Use primaryColor for AppBar
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(horizontalPadding), // Use padding from constants
        child: ListView.builder(
          itemCount: couriers.length,
          itemBuilder: (context, index) {
            final courier = couriers[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners for modern look
              ),
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor, // Use primaryColor for avatar
                  child: Text(
                    courier['name']![0],
                    style: buttonTextStyle, // Use buttonTextStyle for avatar text
                  ),
                ),
                title: Text(
                  courier['name']!,
                  style: subheadingStyle.copyWith(fontSize: 16), // Slightly adjust font size
                ),
                subtitle: Text(
                  courier['location']!,
                  style: bodyTextStyle, // Use bodyTextStyle for subtitles
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: unselectednavbar, // Use unselected color for icons
                  size: 16,
                ),
                onTap: () {
                  // Handle courier details view
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
