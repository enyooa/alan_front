import 'package:alan/bloc/models/debts_row.dart';
import 'package:alan/ui/admin/dynamic_pages/report_pages/debts_report.dart';

abstract class UnifiedDebtsState {}

class UnifiedDebtsInitial extends UnifiedDebtsState {}

class UnifiedDebtsLoading extends UnifiedDebtsState {}

class UnifiedDebtsLoaded extends UnifiedDebtsState {
  final List<DebtsRow> rows;

  UnifiedDebtsLoaded(this.rows);
}

class UnifiedDebtsError extends UnifiedDebtsState {
  final String message;
  UnifiedDebtsError(this.message);
}
