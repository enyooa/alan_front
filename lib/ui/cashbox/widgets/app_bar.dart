import 'package:cash_control/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class CashboxAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const CashboxAppbar({super.key, required this.title, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: primaryColor,
        title: Text(title,style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            // Handle back navigation
          },
        ),
      );
    
    }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}