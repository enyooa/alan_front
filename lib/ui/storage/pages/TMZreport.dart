import 'package:flutter/material.dart';
import 'package:cash_control/constant.dart';

class TMZReport extends StatelessWidget {
  const TMZReport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Section
            
            const SizedBox(height: 16),

            // Create Document Button
            ElevatedButton(
              onPressed: () {
                // Create document logic
              },
              style: elevatedButtonStyle,
              child: const Text('Создать документ', style: buttonTextStyle),
            ),
            const SizedBox(height: 16),

            // Search Bar Headers
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Поиск по контрагенту',
                      style: bodyTextStyle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Дата',
                      style: bodyTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Сумма',
                      style: bodyTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Documents List
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Number of rows
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Документ #${index + 1}',
                            style: bodyTextStyle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '2024-12-${10 + index}',
                            style: bodyTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${(index + 1) * 1000} ₸',
                            style: bodyTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
