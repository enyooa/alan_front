abstract class SalesReportEvent {}

/// Событие получения отчёта "sales"
class FetchSalesReportEvent extends SalesReportEvent {
  final String? startDate;
  final String? endDate;

  FetchSalesReportEvent({this.startDate, this.endDate});
}

/// Можно добавить события для экспорта PDF/Excel, если нужно
class ExportSalesPdfEvent extends SalesReportEvent {
  final String? startDate;
  final String? endDate;
  ExportSalesPdfEvent({this.startDate, this.endDate});
}

class ExportSalesExcelEvent extends SalesReportEvent {
  final String? startDate;
  final String? endDate;
  ExportSalesExcelEvent({this.startDate, this.endDate});
}
