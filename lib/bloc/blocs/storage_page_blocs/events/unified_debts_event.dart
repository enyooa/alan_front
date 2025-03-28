abstract class UnifiedDebtsEvent {}

/// Событие запроса данных. dateFrom / dateTo - могут быть пустые строки
class FetchUnifiedDebtsEvent extends UnifiedDebtsEvent {
  final String? dateFrom;
  final String? dateTo;

  FetchUnifiedDebtsEvent({this.dateFrom, this.dateTo});
}
