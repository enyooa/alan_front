// отчеты
abstract class SalesReportState {}

class SalesReportInitial extends SalesReportState {}

class SalesReportLoading extends SalesReportState {}

class SalesReportLoaded extends SalesReportState {
  final List<Map<String, dynamic>> sales;

  SalesReportLoaded(this.sales);
}

class SalesReportError extends SalesReportState {
  final String error;

  SalesReportError(this.error);
}
