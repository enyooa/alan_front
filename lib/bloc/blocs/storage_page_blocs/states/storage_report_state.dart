
// States
abstract class StorageReportState {}

class StorageReportInitial extends StorageReportState {}

class StorageReportLoading extends StorageReportState {}

class StorageReportLoaded extends StorageReportState {
  final List<Map<String, dynamic>> storageData;

  StorageReportLoaded(this.storageData);
}

class StorageReportError extends StorageReportState {
  final String message;

  StorageReportError(this.message);
}