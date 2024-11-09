import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  _OnbordingState createState() => _OnbordingState();
}

class _OnbordingState extends State<Onboarding> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false); // Save the flag to indicate onboarding is complete
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          contents[i].image!,
                          height: 300,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          contents[i].title!,
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        contents[i].discription!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length,
                (index) => buildDot(index, context),
              ),
            ),
          ),
          Container(
            height: 60,
            margin: const EdgeInsets.all(40),
            width: double.infinity,
            child: TextButton(
              child: Text(
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.blueAccent
                  ),
                currentIndex == contents.length - 1 ? "Продолжить" : "Далее",
              ),
              onPressed: () {
                if (currentIndex == contents.length - 1) {
                  _completeOnboarding();  // Mark onboarding as complete and navigate to home
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.bounceIn,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class UnbordingContent {
  String? image;
  String? title;
  String? discription;

  UnbordingContent({this.image, this.title, this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
    title: 'Склад',
    image: 'assets/images/грузперевозщик.png',
    discription: "Вся информация о товарах, ценах и остатках. История движения в карточке товара. "
        "Инвентаризация, списания и перемещения.",
  ),
  UnbordingContent(
    title: 'Продажи',
    image: 'assets/images/касса.png',
    discription: "Оформляйте продажи/возвраты в основном и кассовых приложениях. Все документы в одном журнале.",
  ),
  UnbordingContent(
    title: 'Контроль',
    image: 'assets/images/контроль.png',
    discription: "Отчеты по продажам, сотрудникам и движению товара. Данные о продажах с касс сразу попадают в приложение.",
  ),
];
