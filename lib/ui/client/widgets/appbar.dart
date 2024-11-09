import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const MainAppBar({super.key, required this.title, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleTextStyle: const TextStyle(),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(CupertinoIcons.back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null, // No back button if showBackButton is false
      title: Row(
        children: [
          const SizedBox(width: 20,),
          Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
        ],
      ),
      
      centerTitle: false,
      titleSpacing: 0.0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // Notification action
          },
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(10),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey[300],
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}