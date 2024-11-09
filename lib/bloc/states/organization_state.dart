import 'package:equatable/equatable.dart';

abstract class OrganizationState extends Equatable {
  const OrganizationState();

  @override
  List<Object?> get props => [];
}

class OrganizationInitial extends OrganizationState {}

class OrganizationLoading extends OrganizationState {}

class OrganizationLoaded extends OrganizationState {
  final List<dynamic> organizations;

  const OrganizationLoaded(this.organizations);

  @override
  List<Object?> get props => [organizations];
}

class OrganizationCreated extends OrganizationState {}

class OrganizationUpdated extends OrganizationState {}

class OrganizationDeleted extends OrganizationState {}

class OrganizationError extends OrganizationState {
  final String message;

  const OrganizationError(this.message);

  @override
  List<Object?> get props => [message];
}
