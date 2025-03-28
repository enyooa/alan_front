abstract class DocsEvent {}

/// Загрузить все документы
class FetchDocsEvent extends DocsEvent {}

/// Удалить документ
class DeleteDocEvent extends DocsEvent {
  final int docId;
  DeleteDocEvent(this.docId);
}

/// Создать документ (пример)
class CreateDocEvent extends DocsEvent {
  final String docType;
  // ... другие поля для создания?
  CreateDocEvent(this.docType);
}
