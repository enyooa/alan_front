import 'package:alan/bloc/models/doc_item.dart';

abstract class DocsState {}

class DocsInitial extends DocsState {}

class DocsLoading extends DocsState {}

class DocsLoaded extends DocsState {
  final List<DocItem> docs;
  DocsLoaded(this.docs);
}

class DocsError extends DocsState {
  final String message;
  DocsError(this.message);
}

/// Можно и промежуточные состояния (DocsCreating, DocsDeleting и т.д.)
