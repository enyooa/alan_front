import 'package:equatable/equatable.dart';

abstract class OrganizationEvent extends Equatable {
  const OrganizationEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrganizationsEvent extends OrganizationEvent {}

class CreateOrganizationEvent extends OrganizationEvent {
  final String name;
  final String currentAccounts;
  final String address;

  const CreateOrganizationEvent({
    required this.name,
    required this.currentAccounts,
    this.address = '',
  });

  @override
  List<Object?> get props => [name, currentAccounts, address];
}

class UpdateOrganizationEvent extends OrganizationEvent {
  final int organizationId;
  final String name;
  final String currentAccounts;
  final String address;

  const UpdateOrganizationEvent({
    required this.organizationId,
    required this.name,
    required this.currentAccounts,
    this.address = '',
  });

  @override
  List<Object?> get props => [organizationId, name, currentAccounts, address];
}

class DeleteOrganizationEvent extends OrganizationEvent {
  final int organizationId;

  const DeleteOrganizationEvent(this.organizationId);

  @override
  List<Object?> get props => [organizationId];
}
