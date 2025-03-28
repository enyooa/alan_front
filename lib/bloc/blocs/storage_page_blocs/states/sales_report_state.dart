import 'package:alan/bloc/models/sale_row.dart';
import 'package:alan/ui/admin/dynamic_pages/report_pages/sales_report.dart';

abstract class SalesReportState {}

class SalesReportInitial extends SalesReportState {}

class SalesReportLoading extends SalesReportState {}

class SalesReportLoaded extends SalesReportState {
  final List<SalesRow> salesData;

  SalesReportLoaded(this.salesData);
}

class SalesReportError extends SalesReportState {
  final String message;
  SalesReportError(this.message);
}
