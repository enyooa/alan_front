// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:alan/bloc/events/organization_event.dart';
// import 'package:alan/bloc/states/organization_state.dart';
// // import 'package:alan/bloc/services/organization_service.dart';

// class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
//   final OrganizationService organizationService;

//   OrganizationBloc({required this.organizationService}) : super(OrganizationInitial()) {
//     on<CreateOrganizationEvent>(_onCreateOrganization);
//   }

//   Future<void> _onCreateOrganization(CreateOrganizationEvent event, Emitter<OrganizationState> emit) async {
//     emit(OrganizationLoading());
//     final success = await organizationService.createOrganization(event.name, event.currentAccounts);

//     if (success) {
//       emit(OrganizationCreated());
//     } else {
//       emit(OrganizationError('Failed to create organization'));
//     }
//   }
// }
