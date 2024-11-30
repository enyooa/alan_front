import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class RussianCalendar {
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ru', 'RU'),
      builder: (BuildContext context, Widget? child) {
        return Localizations(
          locale: const Locale('ru', 'RU'),
          delegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          child: child!,
        );
      },
    );
  }
}
