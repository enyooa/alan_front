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
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: Colors.blue,
            textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Raleway'),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('ru', 'RU'),
            child: child!,
          ),
        );
      },
    );
  }
}
