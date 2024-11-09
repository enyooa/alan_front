import 'dart:math';
import 'package:flutter/material.dart';

class RotatingMenuHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Current Location',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Background(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search for 'Grocery'",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),

              // Rotating menu items
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RotatingMenuItem(
                      icon: Icons.food_bank,
                      label: 'Meets',
                      rotationDegrees: 10,
                    ),
                    RotatingMenuItem(
                      icon: Icons.spa,
                      label: 'Vege',
                      rotationDegrees: -10,
                    ),
                    RotatingMenuItem(
                      icon: Icons.local_pizza,
                      label: 'Fruits',
                      rotationDegrees: 15,
                    ),
                    RotatingMenuItem(
                      icon: Icons.bakery_dining,
                      label: 'Breads',
                      rotationDegrees: -15,
                    ),
                  ],
                ),
              ),
              // Additional content below
              const SizedBox(height: 20),
              // Add your additional UI content here
            ],
          ),
        ],
      ),
    );
  }
}

class RotatingMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double rotationDegrees;

  const RotatingMenuItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.rotationDegrees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.rotate(
          angle: rotationDegrees * pi / 180,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            child: Icon(icon, color: Colors.orange, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      width: size.width,
      height: size.height,
      child: const Stack(children: [
        DecorativeElement(degrees: 190, right: 160, top: 90),
        DecorativeElement(degrees: 90, left: -50, top: 5),
        DecorativeElement(degrees: 10, left: -70, top: 140),
        DecorativeElement(degrees: 75, right: -20, top: 150),
        DecorativeElement(degrees: 100, right: -70, top: 300),
        DecorativeElement(degrees: 155, right: 70, top: 350),
      ]),
    );
  }
}

class DecorativeElement extends StatelessWidget {
  final double? top, left, right, bottom, degrees;
  const DecorativeElement({
    Key? key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.degrees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: degrees! * pi / 180,
        child: Icon(
          Icons.eco,
          color: Colors.greenAccent.withOpacity(0.3),
          size: 100,
        ),
      ),
    );
  }
}
