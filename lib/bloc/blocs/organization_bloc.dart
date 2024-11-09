import 'package:cash_control/bloc/services/organization_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/events/organization_event.dart';
import 'package:cash_control/bloc/states/organization_state.dart';

class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  final OrganizationService organizationService;

  OrganizationBloc({required this.organizationService}) : super(OrganizationInitial()) {
    on<CreateOrganizationEvent>(_onCreateOrganization);
  }

  Future<void> _onCreateOrganization(
    CreateOrganizationEvent event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(OrganizationLoading());
    try {
      final response = await organizationService.createOrganization(
        name: event.name,
        currentAccounts: event.currentAccounts,
      );
      if (response.statusCode == 201) {
        emit(OrganizationCreated());
      } else {
        emit(OrganizationError('Failed to create organization'));
      }
    } catch (e) {
      emit(OrganizationError(e.toString()));
    }
  }
}
