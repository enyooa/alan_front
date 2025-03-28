// storage_report_state.dart

import 'package:alan/ui/admin/widgets/storage_report_item.dart';

abstract class StorageReportState {}

class StorageReportInitial extends StorageReportState {}

class StorageReportLoading extends StorageReportState {}

class StorageReportLoaded extends StorageReportState {
  final List<StorageReportItem> storageData;

  StorageReportLoaded(this.storageData);
}

class StorageReportError extends StorageReportState {
  final String message;
  StorageReportError(this.message);
}
