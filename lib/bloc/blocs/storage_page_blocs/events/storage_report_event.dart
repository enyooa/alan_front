// storage_report_event.dart

abstract class StorageReportEvent {}

/// Событие для загрузки отчёта по складу.
/// Параметры могут быть null, если пользователь не выбрал даты.
class FetchStorageReportEvent extends StorageReportEvent {
  final String? dateFrom; // формат 'YYYY-MM-DD'
  final String? dateTo;

  FetchStorageReportEvent({this.dateFrom, this.dateTo});
}
