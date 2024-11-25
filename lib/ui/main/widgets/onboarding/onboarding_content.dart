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
    discription: ""
    "вся информация о товарах ценах и остатках. История движения в карточке товара"
    "Инвентаризация, списания и перемещения."
  ),
  UnbordingContent(
    title: 'Продажи',
    image: 'assets/images/касса.png',
    discription: "Оформляйте продажи/возвраты в основном и кассовых приложениях."
    "Все документы в одном журнале "
    " "
  ),
  UnbordingContent(
    title: 'Контроль',
    image: 'assets/images/контроль.png',
    discription: "Отчеты по продажам"
    "сотрудникам и движению товара, потребительскому спросу."
    "Данные о продажах с касс сразу попадают в приложения "
  ),
];